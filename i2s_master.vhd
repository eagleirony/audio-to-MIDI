library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library work;
use work.aud_param.all;

-- I2S master interface for the SPH0645LM4H MEMs mic
-- Links:
--   - https://diyi0t.com/i2s-sound-tutorial-for-esp32/
--   - https://cdn-learn.adafruit.com/downloads/pdf/adafruit-i2s-mems-microphone-breakout.pdf
--   - https://cdn-shop.adafruit.com/product-files/3421/i2S+Datasheet.PDF

entity i2s_master is
    generic (
        DATA_WIDTH : natural := 32;
        PCM_PRECISION : natural := 18
    );
    port (
        clk             : in  std_logic;
        ctr_reg         : in  std_logic_vector(5 downto 0);

        -- I2S interface to MEMs mic
        i2s_lrcl        : out std_logic;    -- left/right clk (word sel): 0 = left, 1 = right
        i2s_dout        : in  std_logic;    -- serial data: payload, msb first
        i2s_bclk        : out std_logic;    -- Bit clock: freq = sample rate * bits per channel * number of channels
                                            -- (should run at 2-4MHz). Changes when the next bit is ready.
        -- FIFO interface to MEMs mic
        fifo_din        : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        fifo_w_stb      : out std_logic;    -- Write strobe: 1 = ready to write, 0 = busy
        fifo_full       : in  std_logic     -- 1 = not full, 0 = full
    );
end i2s_master;

architecture Behavioral of i2s_master is

    signal sig_bclk_div     : unsigned(4 downto 0) := (others => '0');
    signal sig_bclk         : std_logic := '0';
    signal sig_prev_bclk         : std_logic := '0';
    signal sig_lrclk_div    : unsigned(10 downto 0) := (others => '0');
    signal sig_lrclk        : std_logic := '0';
    signal sig_prev_lrclk   : std_logic := '0';
    
    signal sig_shift_reg        : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal sig_write_fifo       : std_logic := '0';
    signal sig_fifo_reg         : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal sig_ctr  : std_logic_vector(5 downto 0);
    
    type state_t is (reading, switching, writing_l, writing_r);
    signal curr : state_t := reading;
    
begin

    i2s_lrcl <= sig_lrclk;
    i2s_bclk <= sig_bclk;

    fifo_din <= sig_fifo_reg;
    fifo_w_stb <= sig_write_fifo;
    sig_ctr <= ctr_reg;
    -----------------------------------------------------------------------
    -- hint: write code for bclk clock generator:
    -----------------------------------------------------------------------
    --implementation...:

    process (clk)
    begin
        if falling_edge(clk) then
            if sig_bclk_div = "11110" then
                sig_bclk_div <= "00000";
                sig_bclk <= not(sig_bclk);
            else
                sig_bclk_div <= sig_bclk_div + 1;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- hint: write code for lrcl/ws clock generator:
    ------------------------------------------------------------------------
    --implementation...:

    process (sig_bclk)
    begin
        if falling_edge(sig_bclk) then
            if sig_lrclk_div = "11111" then
                sig_lrclk_div <= (others => '0');
                sig_lrclk <= not(sig_lrclk);
            else
                sig_lrclk_div <= sig_lrclk_div + 1;
            end if;
        end if;
    end process;
    
    ------------------------------------------------------------------------
    -- hint: write code for I2S FSM
    ------------------------------------------------------------------------
    --implementation...:

    process (sig_bclk)
    begin
        if falling_edge(sig_bclk) then
            sig_shift_reg <= sig_shift_reg(30 downto 0) & i2s_dout;
        end if;
    end process;
    
    process (clk, sig_lrclk)
    begin
        if rising_edge(clk) then
            curr <= curr;
            case curr is
                when reading =>
                    curr <= reading;
                    if sig_prev_lrclk /= sig_lrclk then
                        sig_prev_lrclk <= sig_lrclk;
                        if sig_ctr(0) = '1' then
                            curr <= switching;
                        end if;
                    end if;
               when switching =>
                    curr <= switching;
                    if sig_prev_bclk /= sig_bclk then
                        sig_prev_bclk <= sig_bclk;
                        if sig_bclk = '1' then
                            curr <= writing_l;
                        else
                            curr <= writing_r;
                        end if;
                    end if;
               when writing_l =>
                    curr <= reading;
               when writing_r =>
                    curr <= reading;
            end case;
        end if;
    end process;
        
    process (curr)
    begin
        sig_write_fifo <= '0';
        if curr = writing_l then
            sig_write_fifo <= sig_ctr(2);
            sig_fifo_reg <= sig_shift_reg;
        end if;
        if curr = writing_r then
            sig_write_fifo <= sig_ctr(1);
            sig_fifo_reg <= sig_shift_reg;
        end if;
    end process;

    --------------------------------------------------
    -- hint: write code for FIFO data handshake
    --------------------------------------------------
    -- hint: Useful link: https://encyclopedia2.thefreedictionary.com/Hand+shake+signal
    --implementation...:

end Behavioral;
