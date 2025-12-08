import 'dart:math';
import '../models/models.dart';

class MaterialCalculator {
  // --- PARTE 1: LÓGICA "RAIZ" ---

  /// 1. Módulo Aramado (Plaquinha 0.60x2.00m)
  /// Calibração (Base 15m²): ~14 placas, 2 rolos arame, 1 saco gesso, 2kg sisal.
  static CalculationResult calculateAramado({
    required double area,
    required double rebaixoHeight, // Altura do rebaixo em metros
  }) {
    // 1. Placa 0.60x0.60 (Plaquinha 60x60 é o padrão para aramado ou 60x200??
    // O prompt diz "Plaquinha 0.60x2.00m" no título mas "Calibração (Base 15m²): ~14 placas".
    // 14 placas de 0.60x0.60 = 5.04m². Isso não bate com 15m².
    // 14 placas de 0.60x2.00 (1.2m²) = 16.8m². Isso bate com 15m² + quebra.
    // Lógica: (Área / 1.20) + 10% quebra.
    double qtdPlacasTecnica = (area / 1.20) * 1.10;
    double qtdPlacasCompra = qtdPlacasTecnica.ceilToDouble();

    // 2. Arame 18 (Cobre)
    // Regra: (Nº Placas * 4 pontos) * (Altura Rebaixo + 0.40m sobra)
    // Rolos: O prompt diz "2 rolos" para 15m². Vamos inferir o tamanho do rolo ou usar kg?
    // Geralmente vende-se por kg. Vamos calcular em KG de arame.
    // Um rolo comum tem 1kg. Se para 15m² (14 placas) usou 2 rolos, são ~2kg.
    // Cada ponto gasta (Altura + 0.40).
    // Total Arame Metros = (qtdPlacasCompra * 4) * (rebaixoHeight + 0.40);
    // Vamos assumir que 1kg de arame rende X metros ou apenas retornar em KGs baseado na calibração.
    // Calibração: 14 placas -> 2 kgs (rolos).
    // Fator = 2 / 14 = ~0.143 kg/placa (muito alto, mas é "raiz").
    double qtdArameKgTecnica = qtdPlacasCompra * 0.143; 
    double qtdArameKgCompra = qtdArameKgTecnica.ceilToDouble(); // Vende por kg/rolo

    // 3. Gesso em Pó (Cola)
    // Calibração: 15m² -> 1 saco 40kg.
    // Fator: 1 / 15 = 0.067 sacos/m².
    double qtdGessoSacosTecnica = area * 0.067;
    double qtdGessoSacosCompra = qtdGessoSacosTecnica.ceilToDouble();

    // 4. Sisal
    // Calibração: 15m² -> 2kg.
    // Fator: 2 / 15 = 0.133 kg/m².
    double qtdSisalKgTecnica = area * 0.133;
    double qtdSisalKgCompra = qtdSisalKgTecnica.ceilToDouble();

    // 5. Prego de Aço (Fixação Tabica) -> Perímetro? 
    // O prompt diz "Fixação Tabica... 1 a cada 60cm de perímetro".
    // Assumindo perímetro quadrado simples raiz da área * 4 se não fornecido.
    // Para ser mais preciso, deveria pedir perímetro. Vamos estimar perímetro = sqrt(area)*4 (quadrado).
    double perimetroEstimado = sqrt(area) * 4;
    double qtdPregosTecnica = perimetroEstimado / 0.60;
    // Vende-se por cento ou kg? Vamos colocar em "Unidades" e depois o usuário compra o pacote.
    double qtdPregosCompra = (qtdPregosTecnica / 100).ceilToDouble() * 100; // Arredonda para centos

    return CalculationResult(
      moduleName: 'Forro Aramado (Plaquinha)',
      area: area,
      materials: [
        MaterialItem(name: 'Placa 0.60x2.00m', quantityTechnical: qtdPlacasTecnica, quantityPurchase: qtdPlacasCompra, unit: 'un'),
        MaterialItem(name: 'Arame 18 (Rolo 1kg)', quantityTechnical: qtdArameKgTecnica, quantityPurchase: qtdArameKgCompra, unit: 'kg'),
        MaterialItem(name: 'Gesso Cola (Saco 40kg)', quantityTechnical: qtdGessoSacosTecnica, quantityPurchase: qtdGessoSacosCompra, unit: 'sc'),
        MaterialItem(name: 'Sisal (Mechas)', quantityTechnical: qtdSisalKgTecnica, quantityPurchase: qtdSisalKgCompra, unit: 'kg'),
        MaterialItem(name: 'Prego de Aço (Fixação)', quantityTechnical: qtdPregosTecnica, quantityPurchase: qtdPregosCompra, unit: 'un'),
      ],
    );
  }

  /// 2. Módulo Estruturado (F530)
  static CalculationResult calculateEstruturado({
    required double width,
    required double length,
    required bool isRecessed, // "Tem Rebaixo/Sanca?"
    bool useBigPlate = false, // false = 1.20x1.80, true = 1.20x2.40
  }) {
    double area = width * length;
    
    // Placas
    double plateArea = useBigPlate ? (1.20 * 2.40) : (1.20 * 1.80); // 2.88 ou 2.16
    double qtdPlacasTecnica = (area / plateArea) * 1.05; // 5% quebra padrão drywall
    double qtdPlacasCompra = qtdPlacasTecnica.ceilToDouble();

    // Perfil F530
    // Regra de Ouro: Liso = 1.2 barras/m², Rebaixo = 2.2 barras/m²
    double factorF530 = isRecessed ? 2.2 : 1.2;
    double qtdF530Tecnica = area * factorF530;
    double qtdF530Compra = qtdF530Tecnica.ceilToDouble();

    // Tabica/Cantoneira (Perímetro)
    double perimetro = (width + length) * 2;
    double lenBarraPerfil = 3.0; // Padrão 3m
    double qtdPerimetralTecnica = perimetro / lenBarraPerfil;
    double qtdPerimetralCompra = qtdPerimetralTecnica.ceilToDouble();

    // Parafusos e Banda (Estimativa simplificada para "Raiz")
    // Parafuso GN25: ~30 por placa?
    double qtdGN25 = qtdPlacasCompra * 30; 
    double qtdGN25Compra = (qtdGN25 / 100).ceilToDouble() * 100; // Centos

    return CalculationResult(
      moduleName: isRecessed ? 'Forro Estruturado (Com Rebaixo)' : 'Forro Estruturado (Liso)',
      area: area,
      materials: [
        MaterialItem(name: useBigPlate ? 'Placa ST 1.20x2.40' : 'Placa ST 1.20x1.80', quantityTechnical: qtdPlacasTecnica, quantityPurchase: qtdPlacasCompra, unit: 'un'),
        MaterialItem(name: 'Perfil F530 (Barra 3m)', quantityTechnical: qtdF530Tecnica, quantityPurchase: qtdF530Compra, unit: 'br'),
        MaterialItem(name: 'Tabica/Cantoneira (3m)', quantityTechnical: qtdPerimetralTecnica, quantityPurchase: qtdPerimetralCompra, unit: 'br'),
        MaterialItem(name: 'Parafuso GN25', quantityTechnical: qtdGN25, quantityPurchase: qtdGN25Compra, unit: 'un'),
      ],
    );
  }

  /// 3. Módulo Divisória (Drywall)
  static CalculationResult calculateDivisoria({
    required double width,
    required double height,
  }) {
    double area = width * height; 
    
    // Placa: Área duplicada (Lado A + Lado B)
    double areaTotalPlacas = area * 2;
    double plateArea = 1.20 * 1.80; // Padrão mais fácil de manusear em obra
    double qtdPlacasTecnica = (areaTotalPlacas / plateArea) * 1.05; // 5% quebra
    double qtdPlacasCompra = qtdPlacasTecnica.ceilToDouble();

    // Guias (Chão e Teto)
    double lengthGuias = width * 2; // Chão + Teto
    double lenGuideBar = 3.0;
    double qtdGuiasTecnica = lengthGuias / lenGuideBar;
    double qtdGuiasCompra = qtdGuiasTecnica.ceilToDouble();

    // Montantes (A cada 60cm)
    // Quantidade de espaços = width / 0.60
    // Quantidade de montantes = espaços + 1 (final)
    double qtdMontantesTecnica = (width / 0.60).ceil() + 1.0;
    // Altura do montante deve cobrir o pé direito. Se > 3m precisa de emenda. Assumindo < 3m ou sobra.
    // Vamos contar em barras de 3m.
    double qtdMontantesCompra = qtdMontantesTecnica;

    return CalculationResult(
      moduleName: 'Divisória Drywall',
      area: area,
      materials: [
        MaterialItem(name: 'Placa ST 1.20x1.80', quantityTechnical: qtdPlacasTecnica, quantityPurchase: qtdPlacasCompra, unit: 'un'),
        MaterialItem(name: 'Guia 48/70/90 (3m)', quantityTechnical: qtdGuiasTecnica, quantityPurchase: qtdGuiasCompra, unit: 'br'),
        MaterialItem(name: 'Montante (3m)', quantityTechnical: qtdMontantesTecnica, quantityPurchase: qtdMontantesCompra, unit: 'br'),
        // Isolamento poderia entrar aqui
      ],
    );
  }
}
