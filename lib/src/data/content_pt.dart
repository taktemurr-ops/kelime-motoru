// pt: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesPt = [
  'maçã|Fruta vermelha ou verde', 'pão|Assado no forno', 'rio|Água que corre', 'mar|Grande água salgada',
  'ilha|Terra cercada de água', 'montanha|Monte muito alto', 'floresta|Muitas árvores juntas', 'deserto|Terra seca de areia',
  'nuvem|Flutua no céu', 'chuva|Cai das nuvens', 'neve|Flocos brancos de inverno', 'sol|Estrela do dia',
  'lua|Satélite da Terra', 'estrela|Brilha à noite', 'vento|Ar em movimento', 'gelo|Água congelada',
  'fogo|Chamas e calor', 'pedra|Pedaço de rocha', 'areia|Na praia', 'flor|Nasce no jardim',
  'árvore|Tronco e galhos', 'folha|Pende do galho', 'raiz|Debaixo da planta', 'cachorro|Animal que late',
  'gato|Animal que mia', 'cavalo|Animal de montaria', 'pássaro|Asas e penas', 'peixe|Nada com barbatanas',
  'abelha|Faz mel', 'rato|Pequeno roedor', 'vaca|Dá leite', 'ovelha|Dá lã',
  'pato|Ave que faz quá quá', 'coruja|Ave noturna', 'coelho|Orelhas compridas', 'raposa|Esperta e ruiva',
  'urso|Grande animal da mata', 'leão|Rei dos animais', 'casa|Lugar para morar', 'porta|Abre para entrar',
  'janela|Vidro na parede', 'telhado|Cobre a casa', 'parede|Separa os cômodos', 'cadeira|Para sentar',
  'mesa|Móvel para comer', 'cama|Para dormir', 'lâmpada|Dá luz', 'relógio|Mostra as horas',
  'livro|Tem muitas páginas', 'carta|Chega pelo correio', 'lápis|Para escrever', 'escola|Lugar de aprender',
  'professor|Ensina as crianças', 'médico|Cuida dos doentes', 'cozinheiro|Trabalha na cozinha', 'jardim|Flores e plantas',
  'rua|Caminho da cidade', 'ponte|Atravessa o rio', 'cidade|Muitas casas e gente', 'aldeia|Lugar pequeno',
  'carro|Tem quatro rodas', 'trem|Anda nos trilhos', 'navio|Navega no mar', 'avião|Voa no céu',
  'bicicleta|Duas rodas e pedais', 'leite|Bebida branca', 'água|Para beber', 'queijo|Feito de leite',
  'mel|Doce das abelhas', 'açúcar|Adoça', 'sal|Dá sabor', 'sopa|Prato quente',
  'bolo|Doce de festa', 'ovo|A galinha põe', 'nariz|Para cheirar', 'olho|Para ver',
  'orelha|Para ouvir', 'boca|Para falar', 'mão|Tem cinco dedos', 'pé|Vai no sapato',
  'coração|Bombeia o sangue', 'cabeça|Parte de cima do corpo', 'cabelo|Cresce na cabeça', 'dente|Serve para morder',
  'sapato|Usa-se no pé', 'chapéu|Usa-se na cabeça', 'casaco|Roupa de frio', 'anel|Joia do dedo',
  'cor|Vermelho, azul ou verde', 'música|Notas e canções', 'canção|Canta-se', 'jogo|É divertido',
  'bola|Redonda para jogar', 'manhã|Começo do dia', 'tarde|Depois do almoço', 'noite|Hora escura',
  'semana|Sete dias', 'ano|Doze meses', 'verão|Estação quente', 'inverno|Estação fria',
  'outono|Caem as folhas', 'primavera|Estação das flores', 'amigo|Pessoa querida', 'família|Pais e filhos',
  'criança|Pessoa pequena', 'nome|Como você se chama', 'dinheiro|Para pagar', 'mercado|Lugar de compras',
  'mapa|Mostra o caminho', 'sonho|Imagens ao dormir', 'luz|Ilumina', 'sombra|Escura atrás de você',
];

const List<String> kProverbsPt = [
  'Água mole em pedra dura tanto bate até que fura', 'Quem espera sempre alcança', 'Mais vale tarde do que nunca', 'De grão em grão a galinha enche o papo',
  'Quem não arrisca não petisca', 'Cão que ladra não morde', 'Quem com ferro fere com ferro será ferido', 'Deus ajuda quem cedo madruga',
  'Nem tudo que reluz é ouro', 'A pressa é inimiga da perfeição', 'Em boca fechada não entra mosca', 'Mais vale um pássaro na mão do que dois voando',
  'Quem procura acha', 'Quem ri por último ri melhor', 'A união faz a força', 'Uma andorinha só não faz verão',
  'Querer é poder', 'Roma não se fez num dia', 'Onde há fumaça há fogo', 'Antes só do que mal acompanhado',
  'Cada macaco no seu galho', 'A prática leva à perfeição', 'Quem semeia ventos colhe tempestades',
];

const List<String> kGroupsPt = [
  'Frutas|maçã pera cereja banana uva limão laranja', 'Legumes|cenoura batata cebola tomate pepino alface espinafre', 'Animais|cachorro gato cavalo vaca ovelha cabra burro', 'Aves|pombo corvo coruja águia pardal cegonha papagaio',
  'Cores|vermelho azul verde amarelo branco preto marrom', 'Móveis|cadeira mesa cama armário sofá estante cômoda', 'Corpo|cabeça mão pé nariz olho orelha joelho', 'Roupas|camisa calça saia casaco jaqueta meia vestido',
  'Profissões|médico professor cozinheiro padeiro piloto pintor jardineiro', 'Bebidas|água leite suco café chá chocolate limonada', 'Tempo|chuva neve vento neblina granizo tempestade trovão', 'Veículos|carro trem ônibus navio bicicleta avião trator',
  'Instrumentos|violino violão flauta tambor piano harpa trompete', 'Ferramentas|martelo serra alicate furadeira pá lima tesoura',
];

const List<String> kSynonymsPt = [
  'rápido|veloz', 'grande|enorme', 'pequeno|minúsculo', 'bonito|belo',
  'esperto|astuto', 'começar|iniciar', 'alegre|contente', 'fim|término',
  'caminho|trilha', 'coragem|bravura', 'falar|conversar', 'olhar|observar',
  'andar|caminhar', 'calma|sossego',
];

const List<String> kAntonymsPt = [
  'grande|pequeno', 'longo|curto', 'quente|frio', 'claro|escuro',
  'rápido|lento', 'velho|jovem', 'cheio|vazio', 'alto|baixo',
  'dia|noite', 'duro|mole', 'muito|pouco', 'perto|longe',
  'leve|pesado', 'pobre|rico', 'cedo|tarde', 'aberto|fechado',
  'doente|saudável', 'fácil|difícil',
];
