`timescale 1ns / 1ps


module safecrack_button_fsm_tb;

//Sinais de teste
logic       clk;
logic       rst_n;
logic [3:0] btn;
logic       unlocked;

// -------------------------------------------------------------------------
// Instancia do DUT (Device Under Test)
// -------------------------------------------------------------------------
safecrack_button_fsm dut (
    .clk      (clk),
    .rst_n    (rst_n),
    .btn      (btn),
    .unlocked (unlocked)
);

// -------------------------------------------------------------------------
// Geracao de clock: periodo de 20ns -> 50 MHz
// -------------------------------------------------------------------------
initial clk = 0;
always #10 clk = ~clk;


    // -------------------------------------------------------------------------
    // Task: pressiona o botao por alguns ciclos e solta
    //   - btn e ativo baixo na placa, mas aqui simulamos como ativo baixo:
    //     btn = 0 quando pressionado, btn = 1 quando solto
    //   - hold_cycles: quantos ciclos o botao fica pressionado
    // -------------------------------------------------------------------------

    task press_button(input int btn_idx);
        begin
            btn[btn_idx] = 1'b0;
            #40;                 
            btn[btn_idx] = 1'b1;
            #60;                 
        end
    endtask

    // Task para simular o aperto e soltura de DOIS botões SIMULTANEAMENTE
    task press_two_buttons(input int btn_idx1, input int btn_idx2);
        begin
            btn[btn_idx1] = 1'b0; // Pressiona o primeiro botão
            btn[btn_idx2] = 1'b0; // Pressiona o segundo botão ao mesmo tempo
            #40;                  // Segura ambos por 2 ciclos
            btn[btn_idx1] = 1'b1; // Solta ambos os botões
            btn[btn_idx2] = 1'b1;
            #60;                  // Aguarda a sincronização
        end
    endtask

    //Bloco principal

    // -------------------------------------------------------------------------
    // Sequencia de testes
    // -------------------------------------------------------------------------
    initial begin
        // 1. Condição Inicial
        rst_n = 1'b0;
        btn   = 4'b1111; // Todos os botões soltos
        #50;
        rst_n = 1'b1;    // Libera o reset
        #50;

        $display("-------------------------------------------------");
        $display("[TEMPO %0t] INICIANDO TESTES", $time);

        // ---------------------------------------------------------
        // TESTE 1: Senha Errada
        // ---------------------------------------------------------
        $display("\n[TEMPO %0t] === Teste 1: Tentativa incorreta... ===", $time);
        press_button(0); //Acerta Azul
        press_button(1); //Acerta Amarelo
        press_button(3); //Teste de erro
        
        #50;
        if (unlocked) $display("=== Cofre abriu com senha errada ===");
        else          $display("=== Cofre se manteve fechado apos erro ===");

        // ---------------------------------------------------------
        // TESTE 2: Senha Correta
        // Senha: Azul(0), Amarelo(1), Amarelo(1), Vermelho(3), Verde(2), Verde(2)
        // ---------------------------------------------------------
        $display("\n[TEMPO %0t] === Teste 2: Senha correta (0, 1, 1, 3, 2, 2)... ===", $time);
        press_button(0); 
        press_button(1); 
        press_button(1); 
        press_button(3); 
        press_button(2); 
        press_button(2); 

        #50;
        if (unlocked) $display("=== Cofre abriu ===");
        else          $display("=== Cofre nao abriu com a senha correta. ===");

        // ---------------------------------------------------------
        // TESTE 3: Reset depois de cofre aberto
        // ---------------------------------------------------------
        $display("\n[TEMPO %0t] === Teste 3: Resetando o sistema... ===", $time);
        rst_n = 1'b0; // Aperta botão de reset
        #40;
        
        if (!unlocked) $display("=== Cofre fechou depois do reset ===");
        else           $display("=== Cofre continuou aberto mesmo com reset ===");
        
        rst_n = 1'b1;
        #100;

        // ---------------------------------------------------------
        // TESTE 4: Testar 2 botões pressionados ao mesmo tempo
        // ---------------------------------------------------------
        $display("\n[TEMPO %0t] === Teste 4: Dois botoes apertados juntos... ===", $time);;
        press_button(0); //Acerta 1º passo (Azul) -> Vai para S_BLUE
        
        // Pressiona Amarelo (correto) e Vermelho (incorreto) ao mesmo tempo
        press_two_buttons(1, 3); 

        #50;
        // Se utilizou a validação com !$onehot(), a FSM deve ter retornado para S_IDLE
        press_button(1); // Tenta continuar com o 2º Amarelo
        #50;
        if (dut.current_state == 3'd0)
            $display("SUCESSO: FSM rejeitou/resetou ao detectar dois botoes juntos!");
        else 
            $display("ALERTA: FSM aceitou o aperto simultaneo sem resetar.");

        // Reset para o próximo teste
        rst_n = 1'b0; #40; rst_n = 1'b1; #40;
        
        $display("\n=== Simulacao concluida ===\n");
        $stop;
    end

endmodule