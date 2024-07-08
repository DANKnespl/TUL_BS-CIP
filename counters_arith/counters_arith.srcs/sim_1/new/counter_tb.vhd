----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.04.2022 11:48:02
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter_tb is
--  Port ( );
end counter_tb;

architecture Behavioral of counter_tb is

    constant C_WIDTH : integer := 4;
    constant CLK_P : time := 10 ns; 
    
    -- doplnit vychozi hodnoty, abychom nemeli hodiny U
    signal clk : std_logic;
    signal rst : std_logic;
    signal enable : std_logic;
    signal up_not_down : std_logic;
    signal Q : std_logic_vector(C_WIDTH - 1 downto 0);

begin

    clk <= not clk after CLK_P/2;

    DUT : entity work.counter_generic
        generic map (
            C_WIDTH => C_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            up_not_down => up_not_down,
            Q => Q
        );
        
    TB: process
    begin
        rst <= '1';
        wait for CLK_P;
        rst <= '0';
        wait for CLK_P;
        enable <= '1';
        wait for CLK_P;
        wait;
    end process;

end Behavioral;
