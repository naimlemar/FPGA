-------------------------------------------------------------------------------
-- Copyright 2023 Naim Lemar
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

-- Import the IEEE library and the standard logic package
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Declare the main entity Nios2_Multicore
entity Nios2_Multicore is
    -- Define the input ports for the entity
    Port (
        CLOCK_50 : in STD_LOGIC;  -- Clock input signal
        KEY      : in STD_LOGIC   -- Reset input signal
    );
end Nios2_Multicore;

-- Define the architecture for the Nios2_Multicore entity
architecture Behavioral of Nios2_Multicore is
    -- Declare the nios_multicore component
    -- This is like a "template" that tells VHDL how the nios_multicore component should look
    component nios_multicore is
        Port (
            clock_clk     : in STD_LOGIC;  -- Clock input for the component
            reset_reset_n : in STD_LOGIC   -- Reset input for the component
        );
    end component;

-- Start of the architecture body
begin
    -- Instantiate the nios_multicore component
    -- This is where we actually create a "copy" of the nios_multicore component and connect it
    nios_multicore_0 : nios_multicore
        port map (
            clock_clk     => CLOCK_50,  -- Map the CLOCK_50 signal to the clock_clk port of the component
            reset_reset_n => KEY        -- Map the KEY signal to the reset_reset_n port of the component
        );
-- End of the architecture body
end Behavioral;
