-- Imported Libraries
library ieee;
use ieee.std_logic_1164.all;

-- Beginning of the Entity
entity tb_Top_Module is
end tb_Top_Module;

architecture Behavioral of tb_Top_Module is

-- Required Signals
    signal Main_Clock : std_logic := '0';
    signal Reset : std_logic := '1';
    signal Clock_Select : std_logic := '0';
    signal Wave_Select : std_logic := '0';
    signal Go : std_logic := '0';
    signal Seg : std_logic_vector(6 downto 0);
    signal AN : std_logic_vector(3 downto 0);

begin

-- Porting Clock Divider to its test bench  
    uut: entity work.Top_Module port map (
        Main_Clock => Main_Clock,
        Reset => Reset,
        Clock_Select => Clock_Select,
        Wave_Select => Wave_Select,
        Go => Go,
        Seg => Seg,
        AN => AN
    );

    --------------------------------------------
    -- This Process Block generates 100MHz Clock
    --------------------------------------------
    clock_process : process
    begin
        Main_Clock <= '0';
        wait for 10 ns;
        Main_Clock <= '1';
        wait for 10 ns;
    end process clock_process;

    ----------------------------------------------
    -- This Process Block gives the testing inputs
    ----------------------------------------------      
    stimulus_process : process
    begin
        Reset <= '1';   -- Initialization of the whole design
        Go <= '0';      -- In standby mode
        wait for 100000000 ns;  -- Waiting for 100 ms
        Reset <= '0';   -- Reset signal is low
        wait for 100000000 ns;  -- Waiting for 100 ms
        Go <= '1';      -- Go is high to start data generation
        Clock_Select <= '1';    -- For 250Hz Clock Signal
        Wave_Select <= '0';     -- For SQ1 and SQ2
        wait;
    end process stimulus_process;

end Behavioral;