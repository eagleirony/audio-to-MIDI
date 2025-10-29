library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity i2s_master_TB is
    generic (
        DATA_WIDTH : positive := 32
    );
end i2s_master_TB;

architecture Behavioral of i2s_master_TB is
    
    component i2s_master is
        generic (
            DATA_WIDTH : natural := 32;
            PCM_PRECISION : natural := 18
        );
        port (
            clk             : in  std_logic;
            ctr_reg         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            i2s_lrcl        : out std_logic;
            i2s_dout        : in  std_logic;
            i2s_bclk        : out std_logic;
            fifo_din        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
            fifo_w_stb      : out std_logic;
            fifo_full       : in  std_logic
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
    
    signal sig_rst : std_logic := '0';
    signal sig_rd : std_logic := '0';
    signal sig_empty : std_logic := '0';
    signal sig_dout : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sig_ctr_reg : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    sig_clk <= not sig_clk after 10 ns;

    process begin
        sig_ctr_reg <= (others => '0');
        for data_loop in 0 to 1920 loop 
            wait for 68 ns;
            sig_i2s_dout <= not(sig_i2s_dout);
        end loop;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '1',
                        2 => '1',
                        others => '0');
        for data_loop in 0 to 1920 loop 
            wait for 68 ns;
            sig_i2s_dout <= not(sig_i2s_dout);
        end loop;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '1',
                        2 => '0',
                        others => '0');
        for data_loop in 0 to 1920 loop 
            wait for 68 ns;
            sig_i2s_dout <= not(sig_i2s_dout);
        end loop;
        
        sig_ctr_reg <= (0 => '1',
                        1 => '0',
                        2 => '1',
                        others => '0');
        for data_loop in 0 to 1920 loop 
            wait for 68 ns;
            sig_i2s_dout <= not(sig_i2s_dout);
        end loop;
        
        sig_ctr_reg <= (0 => '0',
                        1 => '1',
                        2 => '1',
                        others => '0');
        for data_loop in 0 to 1920 loop 
            wait for 68 ns;
            sig_i2s_dout <= not(sig_i2s_dout);
        end loop;
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
    
    test_fifo: fifo port map (
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

end Behavioral;