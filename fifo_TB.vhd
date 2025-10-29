library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_TB is
--  Port ( );
    generic (
        DATA_WIDTH : positive := 32;
        FIFO_DEPTH : positive := 5
    );
end fifo_TB;

architecture Behavioral of fifo_TB is

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
            dout    : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    signal sig_clk : std_logic := '0';
    signal sig_rst : std_logic := '0';
    signal sig_wr : std_logic := '0';
    signal sig_rd : std_logic := '0';
    signal sig_din : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sig_empty : std_logic := '0';
    signal sig_full : std_logic := '0';
    signal sig_dout : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    sig_clk <= not sig_clk after 10 ns;

    process is
    begin

      sig_rst <= '1';
      wait for 100 ns;
      sig_rst <= '0';
      wait for 400 ns;
      assert sig_empty = '1' report "Failed to empty on reset";
      assert sig_full = '0' report "Failed to empty on reset";
      sig_din <= x"deadbeef";
      wait for 100 ns;
      assert sig_empty = '1' report "Reading in without wr asserted";
      wait for 100 ns;
      sig_wr <= '1';
      wait until rising_edge(sig_clk);
      sig_wr <= '0';
      assert sig_empty = '0' report "Fifo write failed";
      wait for 100 ns;
      sig_rd <= '1';
      wait until rising_edge(sig_clk);
      sig_rd <= '0';
      assert sig_dout = x"deadbeef" report "Fifo read failed";
      sig_wr <= '1';
      sig_din <= x"c0de0000";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0001";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0002";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0003";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0004";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0005";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0006";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0007";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0008";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0009";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000a";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000b";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000c";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000d";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000e";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de000f";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0010";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0011";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0012";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0013";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0014";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0015";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0016";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0017";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0018";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de0019";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001a";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001b";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001d";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001c";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001e";
      wait until rising_edge(sig_clk);
      sig_wr <= '1';
      sig_din <= x"c0de001f";
      assert sig_full = '0' report "Fifo full early";
      wait until rising_edge(sig_clk);
      assert sig_full = '1' report "Fifo not full";
      sig_wr <= '0';
      sig_rd <= '1';
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0000" report "Fifo read failed";
      assert sig_full = '0' report "Fifo full after read";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0001" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0002" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0003" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0004" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0005" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0006" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0007" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0008" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0009" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000a" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000b" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000c" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000d" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000e" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de000f" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0010" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0011" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0012" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0013" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0014" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0015" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0016" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0017" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0018" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de0019" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de001a" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de001b" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de001c" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de001d" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '1';
      assert sig_dout = x"c0de001e" report "Fifo read failed";
      wait until rising_edge(sig_clk);
      sig_rd <= '0';
      assert sig_dout = x"c0de001f" report "Fifo read failed";
      assert sig_empty = '1' report "Last read signal failed";
      assert sig_full = '0' report "Last read signal failed";

      wait for 1 us;
    end process;

    test: fifo port map (
      clkw => sig_clk,
      clkr => sig_clk,
      rst => sig_rst,
      wr => sig_wr,
      rd => sig_rd,
      din => sig_din,
      empty => sig_empty,
      full => sig_full,
      dout => sig_dout
    );

end Behavioral;
