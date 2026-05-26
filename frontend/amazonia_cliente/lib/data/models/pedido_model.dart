class Pedido {
  final int id;
  final int clienteId;
  final int produtoId;
  final String status;
  final int? prestadorId;

  Pedido({
    required this.id,
    required this.clienteId,
    required this.produtoId,
    required this.status,
    this.prestadorId,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      clienteId: json['cliente_id'],
      produtoId: json['produto_id'],
      status: json['status'],
      prestadorId: json['prestador_id'],
    );
  }
}
