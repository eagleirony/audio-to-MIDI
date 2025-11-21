----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.11.2025 15:20:36
-- Design Name: 
-- Module Name: axis_master - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axis_master is
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
        axis_tdest      : out std_logic;
        fifo_rd           : out std_logic;
        fifo_empty        : in std_logic;
        fifo_data         : in std_logic_vector(DATA_WIDTH-1 downto 0);
        axi_control_reg   : in std_logic_vector(DATA_WIDTH-1 downto 0);
        axi_status_reg    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end axis_master;

architecture arch of axis_master is

    signal sig_axis_tvalid : std_logic;
    signal sig_axis_tlast : std_logic;
    signal sig_t_count : integer := 2;
    signal sig_fifo_initialised : std_logic := '0';
    signal sig_axi_control_reg : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_fifo_empty : std_logic;
    signal sig_fifo_valid_data : std_logic := '0';
    signal sig_axis_tvalid_buf : std_logic := '0';
    signal sig_fifo_rd : std_logic;
    signal sig_axi_status_reg :  std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_tdata_for_fft : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
    
    sig_axi_control_reg <= axi_control_reg;
    sig_fifo_empty <= fifo_empty;
    sig_fifo_rd <= (not sig_fifo_initialised) or ((not fifo_empty) and axis_tready);
    sig_axis_tvalid <= (sig_axis_tvalid_buf or sig_fifo_valid_data);
    axis_tvalid <= sig_axis_tvalid;
    axis_tlast <= sig_axis_tlast;
    fifo_rd <= sig_fifo_rd;
    
    sig_axi_status_reg(31) <= sig_axis_tvalid;
    sig_axi_status_reg(30) <= axis_tready;
    sig_axi_status_reg(29) <= sig_fifo_initialised;
    sig_axi_status_reg(28 downto 0) <= std_logic_vector(to_unsigned(sig_t_count, DATA_WIDTH-3));
    axi_status_reg <= sig_axi_status_reg;
    
    -- TLAST
    process (clk)
    begin
        if (rst = '0') then
            sig_t_count <= 2;
            sig_fifo_initialised <= '0';
            sig_fifo_valid_data <= '0';
            sig_axis_tvalid_buf <= '0';
            sig_axis_tlast <= '0';
        elsif rising_edge(clk) then
            sig_fifo_valid_data <= sig_fifo_rd and (not fifo_empty);
            if (axis_tready = '0') then
                sig_axis_tvalid_buf <= sig_axis_tvalid;
                sig_fifo_initialised <= sig_axis_tvalid;
            else
                sig_axis_tvalid_buf <= sig_fifo_rd and (not fifo_empty);
                sig_fifo_initialised <= sig_fifo_initialised or (not fifo_empty);
            end if;
            if ((sig_axis_tvalid and axis_tready) = '1') then
                sig_axis_tlast <= '0';
                sig_t_count <= sig_t_count + 1;                
                if (sig_t_count = to_integer(unsigned(sig_axi_control_reg(30 downto 0)))) then
                    sig_axis_tlast <= '1';
                    sig_t_count <= 1;
                end if;
            end if;
        end if;
    end process;
    -- axis_tlast <= '1';

    -- TDATA
    -- axis_tdata <= sig_fifo_data_r when (sig_axis_tvalid and axis_tready) = '1' else (others => '0');
    axis_tdest <= sig_axi_control_reg(31);
    
    -- If data going to FFT shift it down to the bottom bits and only use 14 bits;
    
    sig_tdata_for_fft <= "00000000000000000" & fifo_data(28 downto 14);
    axis_tdata <= fifo_data when sig_axi_control_reg(31) = '1' else sig_tdata_for_fft;


end arch;
