library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_signed.all;

entity fifo is
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
        status  : out std_logic_vector((DATA_WIDTH/2)-1 downto 0);
        fft_event : in std_logic_vector(5 downto 0)
    );
end fifo;

architecture arch of fifo is

    type fifo_t is array (0 to 2**FIFO_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : fifo_t;

    signal rdp : unsigned(FIFO_DEPTH downto 0) := (others => '0');
    signal wrp : unsigned(FIFO_DEPTH downto 0) := (others => '0');
    signal int_rdp : unsigned(FIFO_DEPTH-1 downto 0);
    signal int_wrp : unsigned(FIFO_DEPTH-1 downto 0);

    signal sig_used : unsigned(FIFO_DEPTH downto 0);
    signal sig_status : std_logic_vector((DATA_WIDTH/2)-1 downto 0);

    signal sig_full : std_logic;
    signal sig_empty : std_logic;
    
    signal sig_din     : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_dout    : std_logic_vector(DATA_WIDTH-1 downto 0) := x"DEADC0DE";

begin

    --you need to implement the rest of this file
    --hint:
    -- handle write operations on the rising edge of the write clock, remember to increment write pointer
    -- handle read operations on the rising edge of the read clock, remember to increment read pointer
    -- status signal and empty signal can be computed asynchronously against the read/write pointer values
    -- remember to deal with reset signal
    -- output value can be computed asynchronously using the read pointer
    empty <= sig_empty;
    full <= sig_full;
    sig_din <= din;
    dout <= sig_dout;
    status <= sig_status;
    int_rdp <= rdp(FIFO_DEPTH-1 downto 0);
    int_wrp <= wrp(FIFO_DEPTH-1 downto 0);
    sig_used <= wrp - rdp;
    
    sig_status((DATA_WIDTH/2)-1) <= sig_full;
    sig_status((DATA_WIDTH/2)-2) <= sig_empty;
    sig_status((DATA_WIDTH/2)-3 downto FIFO_DEPTH+1) <= (others => '0');
    sig_status(FIFO_DEPTH downto 0) <= std_logic_vector(sig_used);
    
    process (rdp, wrp, int_rdp, int_wrp)
    begin
        if (rdp = wrp) then
            sig_empty <= '1';
            sig_full <= '0';
        else
            sig_empty <= '0';
            if (int_wrp = int_rdp) then
                sig_full <= '1';
            else
                sig_full <= '0';
            end if; 
        end if;
    end process;

    process (clkr, clkw)
    begin
        if (rst = '0') then
            rdp <= (others => '0');
            wrp <= (others => '0');
            sig_dout <= x"DEADC0DE";
        else
            if rising_edge(clkr) then
                if (rd = '1' and sig_empty = '0') then
                    sig_dout <= mem(to_integer(int_rdp));
                    rdp <= rdp + 1;
                end if;
            end if;
            if rising_edge(clkw) then
                if (wr = '1' and sig_full = '0') then
                    mem(to_integer(int_wrp)) <= sig_din;
                    wrp <= wrp + 1;
                end if;
            end if;
        end if;
    end process;
    
end arch;
