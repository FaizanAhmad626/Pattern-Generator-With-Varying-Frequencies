-- Imported Libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Beginning of the Entity
entity tb_Clock_Divider is
end entity tb_Clock_Divider;

architecture Behavioral of tb_Clock_Divider is

-- Required Signals
    signal Clock_100MHz     : std_logic := '0';
    signal Reset            : std_logic := '0';
    signal Clock_Select     : std_logic := '0';
    signal Divided_Clock    : std_logic;
    signal Clock_250Hz_Out  : std_logic;
    
    begin

-- Porting Clock Divider to its test bench    
    uut: entity work.Clock_Divider
    port map (
        Clock_100MHz => Clock_100MHz,
        Reset => Reset,
        Clock_Select => Clock_Select,
        Divided_Clock => Divided_Clock
    );
        
    --------------------------------------------
    -- This Process Block generates 100MHz Clock
    --------------------------------------------        
    ClockProcess: process
    begin
        Clock_100MHz <= '0';
        wait for 5 ns;
        Clock_100MHz <= '1';
        wait for 5 ns;
    end process ClockProcess;
    
    ----------------------------------------------
    -- This Process Block gives the testing inputs
    ----------------------------------------------      
    Stimulus: process
    begin
        Reset <= '1';   -- Initialization of Clock Divider
        wait for 20 ns; -- Waiting for 2 Clock Cycles
        Reset <= '0';   -- Reset signal is low
        Clock_Select <= '0';    -- For 1Hz Clock Signal
        wait;
    end process Stimulus;
    
end architecture Behavioral;