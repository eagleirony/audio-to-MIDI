library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.aud_param.all;

entity audio_pipeline is
    generic(
        PCM_PRECISION : integer := 18;
        PCM_WIDTH : integer := 24;
        DATA_WIDTH : integer := 32;
        FIFO_DEPTH : integer := 12;
        TRANSFER_LEN : integer := 5;
		C_S00_AXI_DATA_WIDTH    : integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
    );
    port(
        clk: in std_logic;
        rst: in std_logic;

        --------------------------------------------------
        -- I2S
        --------------------------------------------------
        i2s_bclk        : out std_logic;
        i2s_lrcl        : out std_logic;
        i2s_dout        : in  std_logic;
        i2s2_dout       : out std_logic;
        pmod_led_d1     : out std_logic;

        --------------------------------------------------
        -- AXI4-Stream out
        --------------------------------------------------
        axis_o_tdata      : out std_logic_vector(DATA_WIDTH-1 downto 0);
        axis_o_tvalid     : out std_logic;
        axis_o_tready     : in  std_logic;
        axis_o_tlast      : out std_logic;
        
        --------------------------------------------------
        -- AXI4-Stream In
        --------------------------------------------------
        axis_i_tdata      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        axis_i_tvalid     : in  std_logic;
        axis_i_tready     : out std_logic;
        axis_i_tlast      : in  std_logic;
        
        --------------------------------------------------
        -- Control interface (AXI4-Lite)
        --------------------------------------------------
		s00_axi_aclk	: in  std_logic;
		s00_axi_aresetn	: in  std_logic;
		s00_axi_awaddr	: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in  std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in  std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in  std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in  std_logic;
		s00_axi_araddr	: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in  std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in  std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in  std_logic;
		
		--------------------------------------------------
        -- FFT status signals
        --------------------------------------------------
        xfft_event      : in std_logic_vector(5 downto 0);
        
        --------------------------------------------------
        -- BTN input
        --------------------------------------------------
        btn_in          : in std_logic
    );
end audio_pipeline;

architecture Behavioural of audio_pipeline is
    --------------------------------------------------
    -- Data FIFO
    --------------------------------------------------
    signal sig_dfifo_rst             : std_logic;
    signal sig_dfifo_wr              : std_logic;
    signal sig_dfifo_rd              : std_logic;
    signal sig_dfifo_full            : std_logic;
    signal sig_dfifo_empty           : std_logic;
    signal sig_dfifo_data_w          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_dfifo_data_r          : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    --------------------------------------------------
    -- Feedback FIFO
    --------------------------------------------------
    signal sig_fbfifo_rst             : std_logic;
    signal sig_fbfifo_wr              : std_logic;
    signal sig_fbfifo_rd              : std_logic;
    signal sig_fbfifo_full            : std_logic;
    signal sig_fbfifo_empty           : std_logic;
    signal sig_fbfifo_data_w          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_fbfifo_data_r          : std_logic_vector(DATA_WIDTH-1 downto 0);

    --------------------------------------------------
    -- Control interface (AXI4-Lite)
    --------------------------------------------------
    signal sig_i2s_control_reg          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_status_1_reg           : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_status_2_reg           : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_axi_control_reg             : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_version_reg             : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal sig_i2s_mic_d : std_logic;
    signal sig_i2s_slv_d : std_logic;
    signal sig_i2s_d_mux : std_logic;
    
    signal sig_m_axis_status       : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal sig_i2s_lrclk : std_logic;
    signal sig_i2s_bclk : std_logic;
    
    type axis_in_state_t is (transferring, last, wait_on_ready, wait_on_fifo, read_fifo);
    signal axis_in_curr : axis_in_state_t := wait_on_fifo;
    
    signal transfer_cnt : integer;
    
begin
    sig_version_reg <= btn_in & "000" & x"0000016";
    
    i2s2_dout <= sig_i2s_d_mux;
    pmod_led_d1 <= sig_i2s_control_reg(6);
    
    sig_i2s_mic_d <= i2s_dout;
    i2s_bclk <= sig_i2s_bclk;
    i2s_lrcl <= sig_i2s_lrclk;
    
    --------------------------------------------------
    -- Control bus
    --------------------------------------------------
    inst_ctrl_bus : ctrl_bus
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
        cb_i2s_control_reg  => sig_i2s_control_reg,
        cb_status_1_reg   => sig_status_1_reg,
        cb_status_2_reg   => sig_status_2_reg,
        cb_status_3_reg    => sig_m_axis_status,
        cb_axi_control_reg     => sig_axi_control_reg,
        cb_version_reg => sig_version_reg,

		S_AXI_ACLK	    => s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	    => s00_axi_wdata,
		S_AXI_WSTRB	    => s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	    => s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	    => s00_axi_rdata,
		S_AXI_RRESP	    => s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

    sig_i2s_d_mux <= sig_i2s_slv_d when sig_i2s_control_reg(6) = '1' else sig_i2s_mic_d;

    --------------------------------------------------
    -- I2S Master
    --------------------------------------------------
    inst_i2s_master : i2s_master
    generic map (
        DATA_WIDTH      => DATA_WIDTH,
        PCM_PRECISION   => PCM_PRECISION
    )
    port map (
        clk             => clk,
        ctr_reg         => sig_i2s_control_reg(5 downto 0),

        i2s_lrcl        => sig_i2s_lrclk,
        i2s_dout        => sig_i2s_d_mux,
        i2s_bclk        => sig_i2s_bclk,

        fifo_din        => sig_dfifo_data_w,
        fifo_w_stb      => sig_dfifo_wr,
        fifo_full       => sig_dfifo_full
    );

    --------------------------------------------------
    -- Data FIFO
    --------------------------------------------------
    data_fifo : fifo 
    generic map (
        data_width => DATA_WIDTH,
        fifo_depth => FIFO_DEPTH
    ) port map (
        clkw            => clk,
        clkr            => clk,
        rst             => rst,

        wr              => sig_dfifo_wr,
        din             => sig_dfifo_data_w,
        full            => sig_dfifo_full,

        rd              => sig_dfifo_rd,
        dout            => sig_dfifo_data_r,
        empty           => sig_dfifo_empty,
        status          => sig_status_1_reg,
        
        fft_event       => xfft_event
    );
    
    
    --------------------------------------------------
    -- Feedback i2s slave
    --------------------------------------------------
    feedback_i2s_slave: i2s_slave port map (
      clk => clk,
      ctr_reg => sig_i2s_control_reg(5 downto 0),
      i2s_lrcl => sig_i2s_lrclk,
      i2s_dout => sig_i2s_slv_d,
      i2s_bclk => sig_i2s_bclk,
      fifo_dout => sig_fbfifo_data_r,
      fifo_r_stb => sig_fbfifo_rd,
      fifo_empty => sig_fbfifo_empty
    );

    --------------------------------------------------
    -- Feedback FIFO
    --------------------------------------------------
    feedback_fifo : fifo 
    generic map (
        data_width => DATA_WIDTH,
        fifo_depth => FIFO_DEPTH
    ) port map (
        clkw            => clk,
        clkr            => clk,
        rst             => rst,

        wr              => sig_fbfifo_wr,
        din             => sig_fbfifo_data_w,
        full            => sig_fbfifo_full,

        rd              => sig_fbfifo_rd,
        dout            => sig_fbfifo_data_r,
        empty           => sig_fbfifo_empty,
        status          => sig_status_2_reg,
        
        fft_event       => xfft_event
    );

    --------------------------------------------------
    -- AXIS to Feedback FIFO
    --------------------------------------------------

    axis_s : axis_slave port map (
        clk => clk,
        rst => rst,
        axis_tdata => axis_i_tdata,
        axis_tvalid => axis_i_tvalid,
        axis_tready => axis_i_tready,
        axis_tlast => axis_i_tlast,
        fifo_wr => sig_fbfifo_wr,
        fifo_full => sig_fbfifo_full,
        fifo_data => sig_fbfifo_data_w,
        axi_control_reg => sig_axi_control_reg
    );

    --------------------------------------------------
    -- Data FIFO to AXIS
    --------------------------------------------------
    
    axis_m : axis_master port map (
        clk => clk,
        rst => rst,
        axis_tdata => axis_o_tdata,
        axis_tvalid => axis_o_tvalid,
        axis_tready => axis_o_tready,
        axis_tlast => axis_o_tlast,
        fifo_rd => sig_dfifo_rd,
        fifo_empty => sig_dfifo_empty,
        fifo_data => sig_dfifo_data_r,
        axi_control_reg => sig_axi_control_reg,
        axi_status_reg => sig_m_axis_status
    );

end Behavioural;