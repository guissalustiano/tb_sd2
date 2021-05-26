library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity regfile_tb is end;

architecture behaviour of regfile_tb is
    component regfile is
        generic(
            regn : natural := 32;
            wordSize: natural := 64
        );
        port(
            clock: in bit;
            reset: in bit;
            regWrite: in bit;
            rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
            d: in bit_vector(wordSize-1 downto 0);
            q1, q2: out bit_vector(wordSize-1 downto 0)
        );     
    end component;

    constant period: time := 2 fs;
    constant regn: natural := 32;
    constant wordSize: natural := 12;
    signal ck,rst,regW: bit;
    signal rr1TB,rr2TB,wrTB: bit_vector(natural(ceil(log2(real(regn))))-1 downto 0);
    signal dTB,q1TB,q2TB: bit_vector(wordSize-1 downto 0);
    signal oneTB: bit :='0';

begin

    ck <= oneTB and (not ck) after period/2;

    dutA: regfile generic map(regn,wordSize)
          port map(ck,rst,regW,rr1TB,rr2TB,wrTB,dTB,q1TB,q2TB);

    test: process begin
        report "Início";
        oneTB<='1';

        --Teste regW
        wait until rising_edge(ck);
        rst<='0';
        regW<='0';
        wrTB<="01010";
        dTB<=x"02A";
        rr1TB<="01010";
        wait until rising_edge (ck);
        wait for 0.5 fs;
        assert q1TB=x"000" report "Erro RegWrite: escreve quando baixo";

        wait until rising_edge(ck);
        regW<='1';
        rr1TB<="01011";
        rr2TB<="01010";
        wait until rising_edge(ck);
        wait for 0.5 fs;
        assert q1TB=x"000" report "Mal inicializado";
        assert q2TB=x"02A" report "Erro RegWrite: não escreve quando alto";

        --Teste último reg
        wait until rising_edge(ck);
        wrTB<="11111";
        dTB<=x"03B";
        rr1TB<="11111";
        wait until rising_edge(ck);
        wait for 0.5 fs;
        assert q1TB=x"000" report "Ultimo registrador com conteúdo diferente de 0";

        --Teste leitura
        rr1TB<="01010";
        wait for 0.5 fs;
        assert q1TB=x"02A" report "Erro na leitura: conteúdo não foi gravado no banco";
        
        --Teste reset
        wait until rising_edge(ck);
        rst<='1';
        wait for 0.5 fs;
        assert q1TB=x"000" and q2TB=x"000" report "Erro no reset";

        wait until rising_edge(ck);
        oneTB<='0';
        report "Fim";

        wait;
    end process;
end architecture;
