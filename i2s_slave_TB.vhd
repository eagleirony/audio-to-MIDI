library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2s_slave_TB is
    generic (
        DATA_WIDTH : positive := 32
    );
end i2s_slave_TB;

architecture Behavioral of i2s_slave_TB is
    
    component i2s_master is
        generic (
            DATA_WIDTH : natural := 32;
            PCM_PRECISION : natural := 18
        );
        port (
            clk             : in  std_logic;
            ctr_reg         : in  std_logic_vector(5 downto 0);
            i2s_lrcl        : out std_logic;
            i2s_dout        : in  std_logic;
            i2s_bclk        : out std_logic;
            fifo_din        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            fifo_w_stb      : out std_logic;
            fifo_full       : in  std_logic
        );
    end component;
    
    component i2s_slave is
    generic (
        DATA_WIDTH : natural := 32;
        PCM_PRECISION : natural := 18
    );
    port (
        clk             : in  std_logic;
        ctr_reg         : in  std_logic_vector(5 downto 0);
        i2s_lrcl        : in std_logic;    -- left/right clk (word sel): 0 = left, 1 = right
        i2s_dout        : out  std_logic;    -- serial data: payload, msb first
        i2s_bclk        : in std_logic;    -- Bit clock: freq = sample rate * bits per channel * number of channels
        fifo_dout       : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        fifo_r_stb      : out std_logic;    -- Write strobe: 1 = ready to write, 0 = busy
        fifo_empty      : in  std_logic     -- 1 = not full, 0 = full
    );
    end component;

    component fifo is
        generic (
            DATA_WIDTH : positive := 32;
            FIFO_DEPTH : positive := 5
        );
        port (
            clkw    : in  std_logic;
            clkr    : in  std_logic;
            rst     : in  std_logic;
            wr      : in  std_logic;
            rd      : in  std_logic;
            din     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            empty   : out std_logic;
            full    : out std_logic;
            dout    : out std_logic_vector(DATA_WIDTH-1 downto 0);
            status  : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    signal sig_clk : std_logic := '0';
    signal sig_i2s_lrcl : std_logic := '0';
    signal sig_i2s_dout : std_logic := '0';
    signal sig_i2s_bclk : std_logic := '0';
    signal sig_fifo_din : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal sig_fifo_w_stb : std_logic := '0';
    signal sig_fifo_full : std_logic := '0';
    signal sig_fifo_status : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal sig_r_fifo_din : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal sig_r_fifo_w_stb : std_logic := '0';
    signal sig_r_fifo_full : std_logic := '0';
    signal sig_r_fifo_status : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal sig_rst : std_logic := '0';
    signal sig_rd : std_logic := '0';
    signal sig_empty : std_logic := '0';
    signal sig_dout : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sig_ctr_reg : std_logic_vector(5 downto 0) := (others => '0');
    
    signal sig_r_rd : std_logic := '0';
    signal sig_r_empty : std_logic := '0';
    signal sig_r_dout : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    sig_clk <= not sig_clk after 10 ns;

    process begin
    
        sig_ctr_reg <= (others => '0');
        
        for i in 0 to 255 loop
            sig_r_fifo_w_stb <= '1';
            sig_r_fifo_din <= conv_std_logic_vector(i, DATA_WIDTH);
            wait until rising_edge(sig_clk);
        end loop;
        sig_r_fifo_w_stb <= '0';

        wait for 10 * 128 ns;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '1',
                        2 => '1',
                        others => '0');
        wait for 10 * 1000 * 60 ns;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '1',
                        2 => '0',
                        others => '0');
        wait for 10 * 1000 * 60 ns;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '0',
                        2 => '1',
                        others => '0');
        wait for 10 * 1000 * 60 ns;
        
        sig_ctr_reg <= (0 => '0',
                        1 => '1',
                        2 => '1',
                        others => '0');
        wait for 10 * 1000 * 60 ns;

        
    end process;

    test_i2s_master: i2s_master port map (
      clk => sig_clk,
      ctr_reg => sig_ctr_reg,
      i2s_lrcl => sig_i2s_lrcl,
      i2s_dout => sig_i2s_dout,
      i2s_bclk => sig_i2s_bclk,
      fifo_din => sig_fifo_din,
      fifo_w_stb => sig_fifo_w_stb,
      fifo_full => sig_fifo_full
    );
    
    test_write_fifo: fifo port map (
      clkw => sig_clk,
      clkr => sig_clk,
      rst => sig_rst,
      wr => sig_fifo_w_stb,
      rd => sig_rd,
      din => sig_fifo_din,
      empty => sig_empty,
      full => sig_fifo_full,
      dout => sig_dout,
      status => sig_fifo_status
    );
    
    test_i2s_slave: i2s_slave port map (
      clk => sig_clk,
      ctr_reg => sig_ctr_reg,
      i2s_lrcl => sig_i2s_lrcl,
      i2s_dout => sig_i2s_dout,
      i2s_bclk => sig_i2s_bclk,
      fifo_dout => sig_r_dout,
      fifo_r_stb => sig_r_rd,
      fifo_empty => sig_r_empty
    );
    
    test_read_fifo: fifo port map (
      clkw => sig_clk,
      clkr => sig_clk,
      rst => sig_rst,
      wr => sig_r_fifo_w_stb,
      rd => sig_r_rd,
      din => sig_r_fifo_din,
      empty => sig_r_empty,
      full => sig_r_fifo_full,
      dout => sig_r_dout,
      status => sig_r_fifo_status
    );

end Behavioral;