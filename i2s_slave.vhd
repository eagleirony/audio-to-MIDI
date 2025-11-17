library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library work;
use work.aud_param.all;

-- I2S slave interface
-- Links:

entity i2s_slave is
    generic (
        DATA_WIDTH : natural := 32;
        PCM_PRECISION : natural := 18
    );
    port (
        clk             : in  std_logic;
        ctr_reg         : in  std_logic_vector(5 downto 0);

        -- I2S interface to MEMs mic
        i2s_lrcl        : in std_logic;    -- left/right clk (word sel): 0 = left, 1 = right
        i2s_dout        : out  std_logic;    -- serial data: payload, msb first
        i2s_bclk        : in std_logic;    -- Bit clock: freq = sample rate * bits per channel * number of channels
                                            -- (should run at 2-4MHz). Changes when the next bit is ready.
        -- FIFO interface to MEMs mic
        fifo_dout       : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        fifo_r_stb      : out std_logic;    -- Write strobe: 1 = ready to write, 0 = busy
        fifo_empty      : in  std_logic     -- 1 = not full, 0 = full
    );
end i2s_slave;

architecture Behavioral of i2s_slave is

    signal sig_bclk_div     : unsigned(4 downto 0) := (others => '0');
    signal sig_bclk         : std_logic := '0';
    signal sig_prev_bclk    : std_logic := '0';
    signal sig_lrclk_div    : unsigned(10 downto 0) := (others => '0');
    signal sig_lrclk        : std_logic := '0';
    signal sig_prev_lrclk   : std_logic := '0';
    signal sig_i2s_dout     : std_logic := '0';
    
    signal sig_shift_reg       : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sig_read_fifo       : std_logic := '0';
    signal sig_read_fifo_out   : std_logic := '0';

    signal sig_fifo_reg         : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal sig_ctr  : std_logic_vector(5 downto 0);
    
    subtype state_t is integer range 0 to DATA_WIDTH;
    signal curr : state_t := 32;
    
    type fifo_state_t is (start, preread, read, postread, idle);
    signal fifo_curr : fifo_state_t := start;
    
begin

    sig_lrclk <= i2s_lrcl;
    sig_bclk <= i2s_bclk;
    i2s_dout <= sig_i2s_dout;

    sig_fifo_reg <= fifo_dout;
    fifo_r_stb <= sig_read_fifo_out;
    sig_ctr <= ctr_reg;
    -----------------------------------------------------------------------
    -- hint: write code for bclk clock generator:
    -----------------------------------------------------------------------
    --implementation...:

    ------------------------------------------------------------------------
    -- hint: write code for I2S FSM
    ------------------------------------------------------------------------
    --implementation...:



--    process (sig_bclk)
--        variable v_cnt : integer := 0;
--    begin
--        if falling_edge(sig_bclk) then
--            v_cnt := v_cnt + 1;

--            if (v_cnt = 32) then
--                sig_shift_reg <= sig_fifo_reg;
--                sig_i2s_dout <= sig_fifo_reg(31);
--                v_cnt := 0;
--            else
--                sig_shift_reg <= sig_shift_reg(DATA_WIDTH - 1 downto 1) & '0';
--                sig_i2s_dout <= sig_shift_reg(v_cnt - 1);
--            end if;
--        end if;
--    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            fifo_curr <= fifo_curr;
            case fifo_curr is
                when start =>
                    if fifo_empty = '0' then
                        fifo_curr <= preread;
                    end if;
                when idle =>
                    if sig_read_fifo = '1' then
                        fifo_curr <= preread;
                    end if;
                when preread =>
                    fifo_curr <= read;
                when read =>
                    fifo_curr <= postread;
                when postread =>
                    if sig_read_fifo = '0' then
                        fifo_curr <= idle;
                    end if;
            end case;
        end if;
    end process;
                
    process (fifo_curr)
    begin
        sig_read_fifo_out <= '0';
        if fifo_curr = read then
            sig_read_fifo_out <= '1';
        end if;
    end process;
                        

    process (sig_bclk)
    begin
        if rising_edge(sig_bclk) then
            sig_prev_lrclk <= sig_lrclk;
            case curr is
                when 32 =>
                    curr <= 32;
                    if sig_lrclk /= sig_prev_lrclk then
                        curr <= 0;
                    end if;
                when 31 =>
                    curr <= 0;
                when others =>
                    curr <= curr + 1;
            end case;
        end if;
    end process;
        
    process (curr)
    begin
        sig_read_fifo <= '0';
        case curr is
            when 32 =>
                sig_i2s_dout <= '0';
            when 1 =>
                sig_read_fifo <= sig_ctr(0) and ((sig_ctr(2) and sig_lrclk) or (sig_ctr(1) and (not sig_lrclk)));
                sig_i2s_dout <= sig_shift_reg(30);
            when 31 =>
                sig_i2s_dout <= sig_shift_reg(0);
                sig_shift_reg <= fifo_dout;
            when others =>
                sig_i2s_dout <= sig_shift_reg(DATA_WIDTH - curr - 1);
        end case;
    end process;

    --------------------------------------------------
    -- hint: write code for FIFO data handshake
    --------------------------------------------------
    -- hint: Useful link: https://encyclopedia2.thefreedictionary.com/Hand+shake+signal
    --implementation...:

end Behavioral;
