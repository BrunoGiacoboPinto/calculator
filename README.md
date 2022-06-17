# Calculator

Quão difícil é implementar uma calculador em Dart? Vamos descobrir!

## Desafio de programação

Implemente uma calculadora capaz de suportar a mairoria das operações  aritméticas. A calculadora deve ser implementada em duas fases. Na primeira fase, devem ser suportados apneas números inteiros e as seguintes operações aritméticas: adição, subtração, multiplicação e divisão. Na última fase, a calculadora deverá dar suporte a números fracionários e a operações de exponenciação. Essa fase, no entanto, será considerada um bônus.

### Considerações gerais

A implementação deverá atender aos seguintes critérios:

1. Passar em todos testes unitários providos por este repositório;

2. Usar a implementação inicial provida pela classe `CalculatorImpl` presente no arquivo `lib/src/calculator_impl.dart`. Essa será a classe avaliada pelos testes unitários, logo qualquer outra classe resultará em uma implementação invalidada. Está liberado, no entanto, a implementação de qualquer outra classe auxiliar, desde que seja usada pela classe supramencitada;

3. A expressão aritmiética de entrada será do tipo `String` e o resultado final deverá ser de tipo `int` ou `double`, dependendo da fase que você alcançou do desafio;

4. O tratamento da expressão de entrada deverá ser realizado para diversos cenários;

5. A implementação deverá obedecer a precedência de operadores aritméticos;

6. A implementação deverá suportar parênteses balanceados. Ou seja, se houver a abertura de um parêntese para alteração de precedência, um outro deverá estar presente para caracterizar o fechamento da alteração de precedência. Exemplo de expressão inválida: ```1 + 4) / (6 -1```;

7. Os únicos caracteres que constituem uma expressão aritmética válida são: `0,1,2,3,4,5,6,7,8,9,+,-,/,*,(,)` e qualquer variação numérica que represente um `double` válido na sintaxe da linguagem Dart. Valores fracinários, no entanto não poderão passar de 5 números após a vírgula. Para fins de discussão, o conjunto de caracteres válido será chamado de alfabeto;

8. A solução apresentada deverá ser o "mais orientado a objetos possível", ou seja, usar o máximo possível de conceitos do paradigma de programação orientado a objetos que o Dart suportar;

9. Para a segunda fase, erros de arredondamento serão tolerados, desde que seja observado o limite de 5 casas após a vírgula para números fracionários;

10. Não é permitido o uso de nenhuma biblioteca além das bibliotecas padrão da linguagem Dart;

### Como participar do desafio

Para participar do desafio, faça o seguinte:

1. Crie um fork desse repositório;

2. Faça a sua implementação;

3. Crie um pull request para a branch `main` deste repositório contendo um screenshot com todos os testes unitários passando. Esses testes devem ser rodados pelo pipeline do github Actions que já estará pré-configurado. Esse pipeline deverá ser rodado por sua conta;


### Bibliografia

TODO