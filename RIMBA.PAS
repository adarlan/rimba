program destroiTudo;

uses crt;

const
    larguraGrade = 13;
    alturaGrade = 22;
    corBorda = 7;
    corFundo = 0;
    cor: array[1..4] of byte = (10, 12, 14, 9);
    nomeCor: array[1..4] of string = ('Verde   ', 'Vermelho', 'Amarelo ', 'Azul    ');

var
    corGrade: array[1..larguraGrade, 1..alturaGrade] of byte;
    blocoX, blocoY, blocoCor: byte;
    blocoTaCaindo: boolean;
    tempo: integer;
    fimJogo: boolean;
    frequenciaAbsoluta: array[1..4] of integer; {Quantidade de blocos de cada cor eliminados}

procedure desenhaCelula(x, y, corCelula: integer);
    begin
        gotoXY(x + 1, y + 2);
        textColor(corCelula);
        write(#219);
    end;

procedure desenhaGrade;
    var x, y: integer;
    begin
        for x := 1 to larguraGrade do
            for y := 1 to alturaGrade do
                desenhaCelula(x, y, corGrade[x, y]);
    end;

procedure desenhaBorda;
    var x, y: integer;
    begin
        for x := 0 to larguraGrade + 1 do
        begin
            desenhaCelula(x, -1, corBorda);
            desenhaCelula(x, alturaGrade + 1, corBorda);
        end;
        for y := -1 to alturaGrade + 1 do
        begin
            desenhaCelula(0, y, corBorda);
            desenhaCelula(larguraGrade + 1, y, corBorda);
        end;
    end;

procedure inicializaGrade;
    var x, y: integer;
    begin
        for x := 1 to larguraGrade do
            for y := 1 to alturaGrade do
                corGrade[x, y] := corFundo;
    end;

function tecla: char;
    begin
        if keyPressed then
            tecla := readKey;
    end;

function corAleatoria: integer;
    begin
        case random(4) of
            0: corAleatoria := cor[1];
            1: corAleatoria := cor[2];
            2: corAleatoria := cor[3];
            3: corAleatoria := cor[4];
        end;
    end;

procedure inicializaFreqAbs;
    var i: byte;
    begin
        for i := 1 to 4 do
            frequenciaAbsoluta[i] := 0;
    end;

procedure mostraEstatisticas; {Mostra a distribuicao de frequencias e plota um gr fico de barras}
    var frequenciaPercentual: array[1..4] of real; {Percentual de blocos de cada cor eliminados}
        somatorioFreqAbs: integer; {Quantidade total de blocos eliminados}
        i: byte;

    {Desenha uma barra horizontal, dadas posicao, comprimento e cor}
    procedure desenhaBarra(x, y, comprimento, corBarra: byte);
        var cont: byte;
        begin
            gotoXY(x, y);
            write('                            ');
            textColor(corBarra);
            gotoXY(x, y);
            for cont := 1 to comprimento do
                write(#219);
        end;

    begin

        {Calcula o somatorio das frequencias absolutas}
	somatorioFreqAbs := 0;
        for i := 1 to 4 do
            somatorioFreqAbs := somatorioFreqAbs + frequenciaAbsoluta[i];

        for i := 1 to 4 do
        begin
	    {Calcula as frequencias percentuais (fr = 100 * f / n)}
            if somatorioFreqAbs > 0 then {Evitar divisao por zero}
                frequenciaPercentual[i] := 100 * frequenciaAbsoluta[i] / somatorioFreqAbs
            else
                frequenciaPercentual[i] := 0;

	    textColor(cor[i]);
            gotoXY(21, 2 * i + 7);
            write(nomeCor[i], '  ', frequenciaAbsoluta[i]);
            desenhaBarra(40, 2 * i + 7, round(frequenciaPercentual[i] / 5), cor[i]);
            write(' ', frequenciaPercentual[i]:2:2, '%');
        end;
        textColor(15);
        gotoXY(21, 18);
        write('Total     ', somatorioFreqAbs);
    end;

procedure eliminaBlocos;
    var i, x, y: byte;
        cont: integer;
        gradeAux: array[1..larguraGrade, 1..alturaGrade] of byte;
        encontrou: boolean;
    begin
        for x := 1 to larguraGrade do
            for y:=1 to alturaGrade do
                gradeAux[x, y] := 0;
        cont := 0;
        gradeAux[blocoX, blocoY] := 1;
        repeat
            encontrou := true;
            for x := 1 to larguraGrade do
            begin
                for y := 1 to alturaGrade do
                begin
                    if gradeAux[x, y] = 1 then
                    begin
                        if y > 1 then
                            if (corGrade[x, y - 1] = blocoCor) and (gradeAux[x, y - 1] = 0) then
                                gradeAux[x, y - 1] := 1;
                        if y < alturaGrade then
                            if (corGrade[x, y + 1] = blocoCor) and (gradeAux[x, y + 1] = 0) then
                                gradeAux[x, y + 1] := 1;
                        if x > 1 then
                            if (corGrade[x - 1, y] = blocoCor) and (gradeAux[x - 1, y] = 0) then
                                gradeAux[x - 1, y] := 1;
                        if x < larguraGrade then
                            if (corGrade[x + 1, y] = blocoCor) and (gradeAux[x + 1, y] = 0) then
                                gradeAux[x + 1, y] := 1;
                        encontrou := false;
                        gradeAux[x, y] := 2;
                        inc(cont);
                    end;
                end;
            end;
        until encontrou;
        if cont >= 3 then
        begin

            {COLETA DOS DADOS ESTATISTICOS}
            for i := 1 to 4 do
                if blocoCor = cor[i] then
                    frequenciaAbsoluta[i] := frequenciaAbsoluta[i] + cont;
            mostraEstatisticas;

            for x := 1 to larguraGrade do
                for y := 1 to alturaGrade do
                    if gradeAux[x, y] = 2 then
                        corGrade[x, y] := corFundo;
            desenhaGrade;
        end;
    end;

procedure empurraPraCima;
    var x, y: integer;
    begin
        for x := 1 to larguraGrade do
            if corGrade[x, 1] <> corFundo then
                fimJogo := true;
        if not(fimJogo) then
        begin
            for x := 1 to larguraGrade do
                for y := 1 to alturaGrade - 1 do
                    corGrade[x, y] := corGrade[x, y + 1];
            for x := 1 to larguraGrade do
            begin
                if random(5) < 2 then
                    corGrade[x, alturaGrade] := corAleatoria
                else
                    corGrade[x, alturaGrade] := corFundo;
            end;
            desenhaGrade;
        end;
    end;

begin
    textBackground(0);
    clrScr;
    inicializaGrade;
    desenhaGrade;
    desenhaBorda;
    blocoX := 7;
    blocoY := 0;
    blocoCor := corAleatoria;
    blocoTaCaindo := false;
    desenhaCelula(blocoX, blocoY, blocoCor);
    inicializaFreqAbs;
    textColor(15);
    gotoXY(21, 3);
    write('BLOCOS ELIMINADOS');
    gotoXY(21, 6);
    write('Cor       ', 'Qtd      ', 'Percentual');
    mostraEstatisticas;
    textColor(8);
    gotoXY(21, 22);
    write('Bacharelado em Sistemas de Informacao - 2', #167, ' semestre');
    gotoXY(21, 23);
    write('Projeto Interdisciplinar - Raciocinio Logico e Matematico');
    gotoXY(21, 24);
    write('Adarlan Alves Teixeira');
    fimJogo := false;
    tempo := 399;
    repeat
        inc(tempo);
        if tempo = 400 then
        begin
            tempo := 0;
            empurraPraCima;
        end;
        
        if blocoTaCaindo then
        begin
            if (not(blocoY = alturaGrade)) and (corGrade[blocoX, blocoY + 1] = corFundo) then
            begin
                desenhaCelula(blocoX, blocoY, corFundo);
                inc(blocoY);
                desenhaCelula(blocoX, blocoY, blocoCor);
            end
            else
            begin
                corGrade[blocoX, blocoY] := blocoCor;
                eliminaBlocos;
                blocoTaCaindo := false;
                blocoY := 0;
                blocoCor := corAleatoria;
                desenhaCelula(blocoX, blocoY, blocoCor);
            end;
        end;
        
        gotoXY(80, 25);
        delay(20);
        
        case tecla of
            #75:    begin
                    if (not(blocoTaCaindo)) and (blocoX > 1) then
                    begin
                        desenhaCelula(blocoX, blocoY, corFundo);
                        dec(blocoX);
                        desenhaCelula(blocoX, blocoY, blocoCor);
                    end;
                end;
            #77:    begin
                    if (not(blocoTaCaindo)) and (blocoX < larguraGrade) then
                    begin
                        desenhaCelula(blocoX, blocoY, corFundo);
                        inc(blocoX);
                        desenhaCelula(blocoX, blocoY, blocoCor);
                    end;
                end;
            #32:    begin
                    if corGrade[blocoX, 1] = corFundo then
                    begin
                        desenhaCelula(blocoX, blocoY, corFundo);
                        inc(blocoY);
                        desenhaCelula(blocoX, blocoY, blocoCor);
                        blocoTaCaindo := true;
                    end
                    else
                        fimJogo := true;
                end;
            #27:    fimJogo := true;
        end;
        if fimJogo then
        begin
             textbackground(3);
             textColor(blink);
             gotoXY(2, 13);
             write(' FIM DE JOGO ');
             readKey;
        end;
    until fimJogo;
end.

