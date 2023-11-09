----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Faizan Ahmad
-- 
-- Create Date:
-- Design Name: Pattern Generator
-- Module Name: Pattern_Generator - Behavioral
-- Project Name: Pattern_Generator_With_Varying_Frequencies
-- Target Devices: Basys 3 Artix-7 FPGA Trainer Board
-- Tool Versions: Vivado 2023.1
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Beginning of the Entity
entity Pattern_Generator is
    port(
        Divided_Clock   : in  std_logic;    -- Input Clock Signal with 1Hz or 250Hz Frequency
        Reset           : in  std_logic;    -- Reset Signal to reset sequential signals to their initial value
        Go              : in  std_logic;    -- Go signal to initialize data generation
        Wave_Select     : in  std_logic;    -- If '0' then SQ1 and SQ2 will go to output otherwise TRW and SAW
        C0              : out std_logic_vector(7 downto 0); -- First output either contain SQ1 or TRW
        C1              : out std_logic_vector(7 downto 0)  -- Second output either contain SQ2 or SAW
    );
end Pattern_Generator;

architecture Behavioral of Pattern_Generator is

-- Required States, Signals, and Constants
    type State_Type is (IDLE1, IDLE2, SQ1, SQ2, ZERO1, ZERO2, TRW, SAW);    -- States for FSM1 and FSM2
    
    signal Counter1, Counter2 : integer range 0 to 31   := 0;       -- One counter for all waveforms
    signal State1 : State_Type                          := IDLE1;   -- State register for FSM1
    signal State2 : State_Type                          := IDLE2;   -- State register for FSM2
    signal Wave1, Wave2 : std_logic_vector(7 downto 0)  := (others => '0');  -- Signals to store output waveforms
    
    constant SQ1_Counter    : integer := 4;    -- Max counter value for SQ1
    constant TRW_Counter    : integer := 8;    -- Max counter value for TRW
    constant ZERO_Counter   : integer := 16;  -- Max counter value for ZERO1 and ZERO2
    constant SQ2_Counter    : integer := 8;    -- Max counter value for SQ2
    constant SAW_Counter    : integer := 8;    -- Max counter value for SAW

-- Beginning of the Performed Logic
begin
    -------------------------------------------------------------------
    -- This Process Block implements both state machines FSM1 and FSM2
    -------------------------------------------------------------------
    process(Divided_Clock, Reset)   -- Sensitivity List 
    begin
        if Reset = '1' then         -- If Reset is high then initialize the counters from 0, states from IDLE, and outputs from 0
            Counter1 <= 0;
            Counter2 <= 0;
            State1 <= IDLE1;
            State2 <= IDLE2;
            Wave1 <= (others => '0');
            Wave2 <= (others => '0');
        elsif rising_edge(Divided_Clock) then   -- If Reset is low and rising edge of input clock
        
        
            -------
            -- FSM1
            -------
            case State1 is
            
                when IDLE1 =>                   -- State is IDLE1
                    if Go = '1' then            -- If Go is high then proceed otherwise stay in IDLE1 state
                        if Wave_Select = '0' then
                            State1 <= SQ1;
                        else                    -- If Wave Select is 0 then next state is SQ1 otherwise TRW
                            State1 <= TRW;
                        end if;
                    else
                        State1 <= IDLE1;
                    end if;
                    
                when SQ1 =>                         -- State is SQ1
                    if Counter1 = SQ1_Counter - 1 and Wave_Select = '0' then
                        Counter1 <= 0;              -- If Counter1 = 3 then reset the counter and invert the waveform
                        Wave1 <= not Wave1;
                    elsif Wave_Select = '1' then
                        Counter1 <= 0;              -- And if Wave Select is changed by user then go to ZERO1 state
                        State1 <= ZERO1;
                    else
                        Counter1 <= Counter1 + 1;   -- Otherwise just update the counter
                    end if;
                    
                when TRW =>                             -- State is TRW
                    if Counter1 = TRW_Counter - 1 and Wave_Select = '1' then    -- This condition is for the peak of the triangle
                        Counter1 <= Counter1 + 1;       -- If Counter1 = 7 then update the counter and add 31 to waveform
                        Wave1 <= std_logic_vector(unsigned(Wave1) + 31);
                    elsif Counter1 > TRW_Counter - 1 and Wave_Select = '1' then -- This condition is for the second half of the triangle
                        if Wave1 = "11111111" then      -- If Counter1 > 7
                            Counter1 <= Counter1 + 1;   -- And waveform is at its peak then update the counter and subtract 31 from waveform
                            Wave1 <= std_logic_vector(unsigned(Wave1) - 31);
                        elsif Wave1 = "00000000" then
                            Counter1 <= 0;              -- If waveform is at its end then reset the counter
                        else
                            Counter1 <= Counter1 + 1;   -- Otherwise update the counter and subtract 32 from waveform
                            Wave1 <= std_logic_vector(unsigned(Wave1) - 32);
                        end if;
                    elsif Counter1 < TRW_Counter - 1 and Wave_Select = '1' then -- This condition is for the first half of the triangle
                        Counter1 <= Counter1 + 1;       -- If Counter1 < 7 then update the counter and add 32 to waveform
                        Wave1 <= std_logic_vector(unsigned(Wave1) + 32);
                    elsif Wave_Select = '0' then
                        Counter1 <= 0;                  -- And if Wave Select is changed by user then go to ZERO1 state
                        State1 <= ZERO1;
                    end if;
                    
                when ZERO1 =>                       -- State is ZERO1
                    if Counter1 = ZERO_Counter then -- If Counter1 = 16 then reset the counter
                        Counter1 <= 0;
                        if Wave_Select = '0' then
                            State1 <= SQ1;
                        else                        -- If Wave Select is 0 then next state is SQ1 otherwise TRW
                            State1 <= TRW;
                        end if;
                    else                            -- Otherwise send a zero to output and update the counter
                        Wave1 <= (others => '0');
                        Counter1 <= Counter1 + 1;
                    end if;
                when others =>
                    State1 <= IDLE1;                -- Default state is IDLE1
            end case;
            
            
            -------
            -- FSM2
            -------
            case State2 is
            
                when IDLE2 =>                       -- State is IDLE2
                    if Go = '1' then                -- If Go is high then proceed otherwise stay in IDLE2 state
                        if Wave_Select = '0' then
                            State2 <= SQ2;
                        else                        -- If Wave Select is 0 then next state is SQ2 otherwise SAW
                            State2 <= SAW;
                        end if;
                     else
                        State2 <= IDLE2;
                    end if;
                    
                when SQ2 =>                         -- State is SQ2
                    if Counter2 = SQ2_Counter - 1 and Wave_Select = '0' then
                        Counter2 <= 0;              -- If Counter2 = 7 then reset the counter and invert the waveform
                        Wave2 <= not Wave2;
                    elsif Wave_Select = '1' then
                        Counter2 <= 0;              -- And if Wave Select is changed by user then go to ZERO2 state
                        State2 <= ZERO2;
                    else
                        Counter2 <= Counter2 + 1;   -- Otherwise update the counter
                    end if;
                    
                when SAW =>                         -- State is SAW
                    if Counter2 = SAW_Counter - 1 and Wave_Select = '1' then
                        Counter2 <= 0;              -- If Counter2 = 7 then reset the counter as well as the waveform
                        Wave2 <= (others => '0');
                    elsif Counter2 < SAW_Counter - 1 and Wave_Select = '1' then
                        Counter2 <= Counter2 + 1;   -- Otherwise update the counter and add 32 to the waveform
                        Wave2 <= std_logic_vector(unsigned(Wave2) + 32);
                    elsif Wave_Select = '0' then
                        Counter2 <= 0;              -- And if Wave Select is changed by user then go to ZERO2 state
                        State2 <= ZERO2;
                    end if;
                    
                when ZERO2 =>                       -- State is ZERO2
                    if Counter2 = ZERO_Counter then -- If Counter2 = 16 then reset the counter
                        Counter2 <= 0;
                        if Wave_Select = '0' then
                            State2 <= SQ2;
                        else                        -- If Wave Select is 0 then next state is SQ2 otherwise SAW
                            State2 <= SAW;
                        end if;
                    else                            -- Otherwise send a zero to output and update the counter
                        Wave2 <= (others => '0');
                        Counter2 <= Counter2 + 1;
                    end if;
                when others =>
                    State2 <= IDLE2;                -- Default state is IDLE2
            end case;
        end if;
    end process;

    C0 <= Wave1;    -- Assigning first output waveform to C0
    C1 <= Wave2;    -- Assigning second output waveform to C1
end Behavioral;