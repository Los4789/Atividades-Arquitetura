module button_fsm (
    input  logic       clk,    // Clock de 50 MHz
    input  logic       rst_n,  // Reset assincrono, ativo baixo (KEY[0])
    input  logic       btn,    // Botao de avanco, ativo baixo  (KEY[1])
    output logic       pressed // Indica 1 para o botão apertado ao one_hot_encoding
);

logic border1, border2, border3;

always_ff @(posedge clk or negedge rst_n) begin
    //Nivel 1 quando inativos
    if (!rst_n) begin
        border1 <= 1'b1;
        border2 <= 1'b1;
        border3 <= 1'b1;
    end
    else begin
        border1 <= btn;
        border2 <= border1;
        border3 <= border2;
    end
end

//Quando botao apertado e solto (border2 recebe 1, border3 continua em 0 por um pulso)
assign pressed = border2 & ~border3; 
endmodule

module safecrack_button_fsm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] btn,       //Entradas dos botoes
    output logic       unlocked   //1 = aberto, 2 = fechado
);

logic [3:0] btn_pressed;

button_fsm blue (
.clk (clk),
.rst_n (rst_n),
.btn (btn[0]),
.pressed (btn_pressed[0])
);

button_fsm yellow (
.clk (clk),
.rst_n (rst_n),
.btn (btn[1]),
.pressed (btn_pressed[1])
);

button_fsm green (
.clk (clk),
.rst_n (rst_n),
.btn (btn[2]),
.pressed (btn_pressed[2])
);

button_fsm red (
.clk (clk),
.rst_n (rst_n),
.btn (btn[3]),
.pressed (btn_pressed[3])
);

//A senha e: Azul (0), Amarelo (1), Amarelo (1), Vermelho (3), Verde (2), Verde (2)
    typedef enum logic [2:0] {
        S_IDLE    = 3'd0, //Esperando Azul (0)
        S_BLUE    = 3'd1, //Esperando Amarelo (1)
        S_YEL_1   = 3'd2, //Esperando 2º Amarelo (1)
        S_YEL_2   = 3'd3, //Esperando Vermelho (3)
        S_RED     = 3'd4, //Esperando Verde (2)
        S_GRN_1   = 3'd5, //Esperando 2º Verde (2)
        S_OPEN    = 3'd6  //Senha correta
    } state_t;

state_t current_state, next_state;

always_ff @(posedge clk or negedge rst_n) begin
    //Se reset apertado
    if (!rst_n)
        current_state <= S_IDLE;
    else
        current_state <= next_state;
    end

    always_comb begin
        //Padrao para evitar latch
        next_state = current_state; 
        unlocked   = 1'b0;

    // Se pressionar mais de um botão ao mesmo tempo, reseta a sequência
    if (|btn_pressed && !$onehot(btn_pressed)) begin
        next_state = S_IDLE;
    end 
    else begin

        case (current_state)
            S_IDLE: begin
                if (btn_pressed[0])       next_state = S_BLUE; //Azul apertado
                else if (|btn_pressed)    next_state = S_IDLE; //Erro: reinicia
            end

            S_BLUE: begin
                if (btn_pressed[1])       next_state = S_YEL_1; //Amarelo apertado
                else if (|btn_pressed)    next_state = S_IDLE;  //Erro: reinicia
            end

            S_YEL_1: begin
                if (btn_pressed[1])       next_state = S_YEL_2; //Amarelo apertado
                else if (|btn_pressed)    next_state = S_IDLE;  //Erro: reinicia
            end

            S_YEL_2: begin
                if (btn_pressed[3])       next_state = S_RED;   //Vermelho apertado
                else if (|btn_pressed)    next_state = S_IDLE;  //Erro: reinicia
            end

            S_RED: begin
                if (btn_pressed[2])       next_state = S_GRN_1; //Verde apertado
                else if (|btn_pressed)    next_state = S_IDLE;  //Erro: reinicia
            end

            S_GRN_1: begin
                if (btn_pressed[2])       next_state = S_OPEN;  //Verde apertado
                else if (|btn_pressed)    next_state = S_IDLE;  //Erro: reinicia
            end

            S_OPEN: begin
                unlocked = 1'b1;         //Deixa cofre aberto
                next_state = S_OPEN;     //Fica preso neste estado ate o reset
            end

            default: next_state = S_IDLE;
        endcase
        end
    end

endmodule