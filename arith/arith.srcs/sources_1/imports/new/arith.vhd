library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;

entity arith is
    generic(
        C_WIDTH : integer := 8
    );
    port(
        -- output is registered
        clk             : in  std_logic;
        -- operands
        operandA        : in  std_logic_vector(C_WIDTH - 1 downto 0);
        operandB        : in std_logic_vector(C_WIDTH - 1 downto 0);
        -- opcodes + input flags
        opcode          : in  opcode_t;
        -- input is signed
        opcode_signed   : in  std_logic;
        -- do saturated arithmetic   
        opcode_saturate : in  std_logic;
        -- result of operation
        result          : out std_logic_vector(C_WIDTH - 1 downto 0);
        -- output carry
        carry           : out std_logic;
        -- overflow occured
        overflow        : out std_logic;
        -- output is zero
        zero            : out std_logic;
        -- output was saturated
        saturated       : out std_logic
    );
end entity;

architecture RTL of arith is

begin

end architecture RTL;
