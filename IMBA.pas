program rimba;

	const
		L = 30;	// Largura da grade
		A = 20;	// Altura da grade
		TempoSubir = 150;	// Os blocos sobem a cada 6 segundos (150 passos a 25 fps)
		ProbCriar = 2;	// Probabilidade de criar um bloco
		QtdCor = 4;	// Quantidade de cores
		QtdPilha = 3;

	var
		grade: array[1..L, 1..A] of integer;
		n: array[1..L, 1..A] of integer;
		x, y: integer;
		tempo: integer;
		FimJogo: boolean;
		garra_x: integer;
		bloco_x, bloco_y, bloco_cor: integer;
		ok: boolean;
		cont: integer;
		pontos: integer;
	
	procedure	DsnCel(x1, y1, cor: integer);
		// Desenhar Célula: preenche uma célula da grade
		begin
		
			case cor of
			
				0: textcolor(0);	// preto (cor de fundo)
				1: textcolor(2);	// verde
				2: textcolor(12);	// vermelho
				3: textcolor(14);	// amarelo
				4: textcolor(9);	// azul
				5: textcolor(8);	// cinza
				
			end;
			
			gotoxy(x1 + 1, y1 + 2);
			
			write(#219);
			
		end;
	
	procedure DsnGrade;
		// Desenha a grade na janela
		begin
		
			for x:=1 to L do
				for y:=1 to A do
					DsnCel(x, y, grade[x,y]);
		
		end;
	
	procedure DsnGarra;
		// Desenhar a garra na grade
		begin
			
			textbackground(0);
			textcolor(15);
			
			gotoxy(garra_x + 1, 1);
			write(#179);
			gotoxy(garra_x, 2);
			write(#218, #193, #191);
			gotoxy(garra_x, 3);
			write(#192, ' ', #217);
		
		end;
	
	procedure ApgGarra;
		// Apagar a garra na grade
		begin
			
			textbackground(0);
			textcolor(0);
			
			gotoxy(garra_x + 1, 1);
			write(#179);
			gotoxy(garra_x, 2);
			write(#218, #193, #191);
			gotoxy(garra_x, 3);
			write(#192, ' ', #217);
		
		end;
	
	function tecla: char;
		begin
			if keypressed then
				tecla:=readkey;
		end;
	
	begin	// Programa principal
		repeat
		
		textcolor(13);
		for x:=1 to L + 2 do
		begin
			gotoxy(x,A + 3);
			write('#');
		end;
		
		for y:=3 to A + 4 do
		begin
			gotoxy(1,y);
			write('#');
			gotoxy(L + 2,y);
			write('#');
		end;
		
		// Inicializando as células da grade
		for x:=1 to L do
			for y:=1 to A do
				grade[x,y]:=0;	// 0 = preto
		
		garra_x:= (L div 2) + 1;
		DsnGarra;
		
		FimJogo:=false;
		
		bloco_cor:= random(QtdCor) + 1;
		bloco_x:= garra_x;
		bloco_y:= 1;
		
		DsnCel(bloco_x, bloco_y, bloco_cor);
		
		pontos:= 0;
		gotoxy(10,23);
		write('Pontos: ',pontos);
		
		repeat	// Início do passo
		
			gotoxy(80,25);
			
			delay(40);	// 1000/40 = 25 fps
			
			case tecla of
			
			'a':	begin
					if (garra_x > 1) then
					begin
						ApgGarra;
						garra_x:= garra_x - 1;
						DsnGarra;
						
						if bloco_y = 1 then
						begin
							bloco_x:= garra_x;
							DsnCel(bloco_x, bloco_y, bloco_cor);
						end;
						
					end;
				end;
			
			'd':	begin
					if (garra_x < L) then
					begin
						ApgGarra;
						garra_x:= garra_x + 1;
						DsnGarra;
						
						if bloco_y = 1 then
						begin
							bloco_x:= garra_x;
							DsnCel(bloco_x, bloco_y, bloco_cor);
						end;
						
					end;
				end;
			
			' ':	begin
					if bloco_y = 1 then
					begin
						DsnCel(bloco_x, bloco_y, 0);	// Apg bloco
						bloco_y:= 2;
					end;
				end;
			
			end;
			
			tempo:= tempo + 1;
			
			if tempo = TempoSubir then
			begin
			
				tempo:=0;
				
				// os blocos da grade sobem
				for x:=1 to L do
					for y:=1 to (A - 1) do
						grade[x,y]:= grade[x,y+1];
				
				// novos blocos são criados na última linha
				for x:=1 to L do
				begin
					if random(5) < ProbCriar then
						grade[x,A]:= random(QtdCor) + 1
					else
						grade[x,A]:= 0;
				end;
				
				DsnGrade;
				
				DsnGarra;
				
				DsnCel(bloco_x, bloco_y, bloco_cor);
				
				// testar se os blocos atingiram o topo
				for x:=1 to L do
					if grade[x,2] <> 0 then
						FimJogo:=true;
				
			end;
			
			if bloco_y > 1 then
			begin
				DsnCel(bloco_x, bloco_y, 0);
				
				if (bloco_y = A) or (grade[bloco_x,bloco_y + 1] <> 0) then
				begin
					grade[bloco_x,bloco_y]:= bloco_cor;
					DsnCel(bloco_x, bloco_y, bloco_cor);
					
					//-------------------------------		
					for x:=1 to L do
						for y:=1 to A do
							n[x,y]:=0;
					
					cont:= 0;
		     			
					n[bloco_x, bloco_y]:=1;
					
					repeat
						ok:=true;
						for x:=1 to L do
						begin
							for y:=1 to A do
							begin
								
								if n[x,y]=1 then
								begin
						
									if y > 1 then
										if (grade[x,y-1] = bloco_cor) and (n[x,y-1] = 0) then
											n[x,y-1]:=1;
									
									if y < A then
										if (grade[x,y+1] = bloco_cor) and (n[x,y+1] = 0) then
											n[x,y+1]:=1;
						
									if x > 1 then
										if (grade[x-1,y] = bloco_cor) and (n[x-1,y] = 0) then
											n[x-1,y]:=1;
						
									if x < L then
										if (grade[x+1,y] = bloco_cor) and (n[x+1,y] = 0) then
											n[x+1,y]:=1;
							
									ok:=false;
									n[x,y]:=2;
									cont:= cont + 1;
								end;
							end;
						end;
					until(ok);
		
					if cont >= QtdPilha then
					begin
						for x:=1 to L do
							for y:=1 to A do
								if n[x,y]=2 then
									grade[x,y]:= 0;
		
						DsnGrade;
						DsnGarra;
						pontos:= pontos + (cont * cont);
						gotoxy(10,23);
						write('Pontos: ',pontos);
					end;
					//-------------------------------
					
					bloco_cor:= random(QtdCor) + 1;
					bloco_x:= garra_x;
					bloco_y:= 1;
				end
				else
					bloco_y:= bloco_y + 1;
				
				DsnCel(bloco_x, bloco_y, bloco_cor);
			end;
		
		until FimJogo;	// Fim do passo
		
		clrscr;
		writeln('Game Over!');
		
		until false
		
	end.
