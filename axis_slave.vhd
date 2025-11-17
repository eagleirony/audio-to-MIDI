----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 15:20:36
-- Design Name: 
-- Module Name: axis_slave - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_slave is
    generic(
        DATA_WIDTH : integer := 32
    );
    port(
        clk             : in std_logic; 
        rst             : in std_logic;
        axis_tdata      : in std_logic_vector(DATA_WIDTH-1 downto 0);
        axis_tvalid     : in std_logic;
        axis_tready     : out std_logic;
        axis_tlast      : in std_logic;
        fifo_wr           : out std_logic;
        fifo_full         : in std_logic;
        fifo_data         : out std_logic_vector(DATA_WIDTH-1 downto 0);
        axi_control_reg   : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end axis_slave;

architecture arch of axis_slave is

    signal sig_fifo_wr : std_logic;
    signal sig_fifo_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_tready : std_logic;

begin

    axis_tready <= sig_tready;
    sig_tready <= '1'; --when axis_tvalid = '1' else '0';
    fifo_data <= sig_fifo_data;
    fifo_wr <= sig_fifo_wr;

    process (clk)
    begin
        if rising_edge(clk) then
            sig_fifo_wr <= '0';

            if (axis_tvalid = '1') then
                sig_fifo_wr <= '1';
                sig_fifo_data <= axis_tdata;
            end if;
        end if;
    end process;

end arch;
