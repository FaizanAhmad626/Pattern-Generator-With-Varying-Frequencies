-- Imported Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Beginning of the Entity
entity tb_Pattern_Generator is
end entity tb_Pattern_Generator;

architecture Behavioral of tb_Pattern_Generator is

-- Required Signals
    signal Reset         : std_logic := '1';
    signal Go            : std_logic := '0';
    signal Wave_Select   : std_logic := '0';
    signal Divided_Clock : std_logic := '0';
    signal C0            : std_logic_vector(7 downto 0);
    signal C1            : std_logic_vector(7 downto 0);
begin

-- Instantiating Data Generator
    uut : entity work.Pattern_Generator
    port map (
        Reset         => Reset,
        Go            => Go,
        Wave_Select   => Wave_Select,
        Divided_Clock => Divided_Clock,
        C0            => C0,
        C1            => C1
    );
    
    --------------------------------------------
    -- This Process Block generates the Clock
    --------------------------------------------        
--    Clock_Process : process
--    begin           -- Clock frequency is 1 Hz
--        wait for 500000000 ns;
--        Divided_Clock <= '1';
--        wait for 500000000 ns;
--        Divided_Clock <= '0';
--    end process Clock_Process;
    
    --------------------------------------------
    -- This Process Block generates the Clock
    --------------------------------------------        
    Clock_Process : process
    begin           -- Clock frequency is 250 Hz
        wait for 2000000 ns;
        Divided_Clock <= '1';
        wait for 2000000 ns;
        Divided_Clock <= '0';
    end process Clock_Process;
    
    ----------------------------------------------
    -- This Process Block gives the testing inputs
    ----------------------------------------------        
    Stimulus_Process : process
    begin
        Reset <= '1';           -- Initialization of Clock Divider
        Go <= '0';              -- Go is low to test if FSMs stay idle
        wait for 16000000 ns;   -- Waiting for 4 Clock Cycles i.e. 16 ms
        Reset <= '0';           -- Reset signal is low
        wait for 8000000 ns;    -- Waiting for 2 Clock Cycles i.e. 8 ms
        Go <= '1';              -- Go is high to initialize FSMs
        Wave_Select <= '0';     -- For SQ1 and SQ2
        wait for 116000000 ns;  -- Waiting for 29 Clock Cycles i.e. 116 ms
        Wave_Select <= '1';     -- For TRW and SAW
        wait for 192000000 ns;  -- Waiting for 48 Clock Cycles i.e. 192 ms
        Wave_Select <= '0';     -- For SQ1 and SQ2 again
        wait;
    end process Stimulus_Process;
    
end architecture Behavioral;