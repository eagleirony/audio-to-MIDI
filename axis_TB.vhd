----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 15:19:38
-- Design Name: 
-- Module Name: axis_TB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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

entity axis_TB is
--  Port ( );
generic (
        DATA_WIDTH : positive := 32
    );
end axis_TB;

architecture Behavioral of axis_TB is

    component axis_master is
        generic(
            DATA_WIDTH : integer := 32
        );
        port(
            clk             : in std_logic; 
            rst             : in std_logic;
            axis_tdata      : out std_logic_vector(DATA_WIDTH-1 downto 0);
            axis_tvalid     : out std_logic;
            axis_tready     : in  std_logic;
            axis_tlast      : out std_logic;
            fifo_rd           : out std_logic;
            fifo_empty        : in std_logic;
            fifo_data         : in std_logic_vector(DATA_WIDTH-1 downto 0);
            axi_control_reg   : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
    component fifo is
        generic (
            DATA_WIDTH : positive := 32;
            FIFO_DEPTH : positive := 9
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
    component axis_slave is
    generic(
        DATA_WIDTH : integer := 32
    );
    port(
        clk             : in std_logic; 
        rst             : in std_logic;
        axis_tdata      : in std_logic_vector(DATA_WIDTH-1 downto 0);
        axis_tvalid     : in std_logic;
        axis_tready     : out  std_logic;
        axis_tlast      : in std_logic;
        fifo_wr           : out std_logic;
        fifo_full         : in std_logic;
        fifo_data         : out std_logic_vector(DATA_WIDTH-1 downto 0);
        axi_control_reg   : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    end component;

    signal sig_clk : std_logic := '0';
    signal sig_axis_tdata : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_axis_tvalid : std_logic;
    signal sig_axis_tready : std_logic := '0';
    signal sig_axis_tlast : std_logic;
    signal sig_mfifo_rd : std_logic;
    signal sig_mfifo_wr : std_logic;
    signal sig_mfifo_empty : std_logic;
    signal sig_mfifo_dout : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_mfifo_din : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_sfifo_rd : std_logic;
    signal sig_sfifo_wr : std_logic;
    signal sig_sfifo_full : std_logic;
    signal sig_sfifo_dout : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_sfifo_din : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_axi_control_reg : std_logic_vector(DATA_WIDTH-1 downto 0);


begin

sig_clk <= not sig_clk after 10 ns;

process begin
    sig_axi_control_reg <= x"00000100";
    for i in 0 to 127 loop
        sig_mfifo_wr <= '1';
        sig_mfifo_din <= conv_std_logic_vector(i, DATA_WIDTH);
        wait until rising_edge(sig_clk);
    end loop;
    sig_mfifo_wr <= '0';
    wait for 10 * 256 ns;
    
    sig_mfifo_wr <= '1';
    sig_mfifo_din <= conv_std_logic_vector(128, DATA_WIDTH);
    wait until rising_edge(sig_clk);
    sig_mfifo_wr <= '0';
    wait for 10 * 3 ns;
    sig_mfifo_wr <= '1';
    sig_mfifo_din <= conv_std_logic_vector(129, DATA_WIDTH);
    wait until rising_edge(sig_clk);
    sig_mfifo_wr <= '0';
    wait for 10 * 3 ns;
    
    for i in 130 to 254 loop
        sig_mfifo_wr <= '1';
        sig_mfifo_din <= conv_std_logic_vector(i, DATA_WIDTH);
        wait until rising_edge(sig_clk);
    end loop;
    sig_mfifo_wr <= '0';
    
    wait for 10 * 256 ns;
    sig_mfifo_wr <= '1';
    sig_mfifo_din <= conv_std_logic_vector(255, DATA_WIDTH);
    wait until rising_edge(sig_clk);
    sig_mfifo_wr <= '0';
    wait for 10 * 3 ns;
end process;

test_read_fifo: fifo port map (
  clkw => sig_clk,
  clkr => sig_clk,
  rst => '1',
  wr => sig_mfifo_wr,
  rd => sig_mfifo_rd,
  din => sig_mfifo_din,
  empty => sig_mfifo_empty,
  full => open,
  dout => sig_mfifo_dout,
  status => open
);

test_axis_m : axis_master port map (
    clk => sig_clk,
    rst => '1',
    axis_tdata => sig_axis_tdata,
    axis_tvalid => sig_axis_tvalid,
    axis_tready => sig_axis_tready,
    axis_tlast => sig_axis_tlast,
    fifo_rd => sig_mfifo_rd,
    fifo_empty => sig_mfifo_empty,
    fifo_data => sig_mfifo_dout,
    axi_control_reg => sig_axi_control_reg
    );
    
test_write_fifo: fifo port map (
  clkw => sig_clk,
  clkr => sig_clk,
  rst => '1',
  wr => sig_sfifo_wr,
  rd => sig_sfifo_rd,
  din => sig_sfifo_din,
  empty => open,
  full => sig_sfifo_full,
  dout => sig_sfifo_dout,
  status => open
);

test_axis_s : axis_slave port map (
    clk => sig_clk,
    rst => '1',
    axis_tdata => sig_axis_tdata,
    axis_tvalid => sig_axis_tvalid,
    axis_tready => sig_axis_tready,
    axis_tlast => sig_axis_tlast,
    fifo_wr => sig_sfifo_wr,
    fifo_full => sig_sfifo_full,
    fifo_data => sig_sfifo_din,
    axi_control_reg => sig_axi_control_reg
    );


end Behavioral;
