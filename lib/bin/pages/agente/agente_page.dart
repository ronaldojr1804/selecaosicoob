// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:selecaosicoob/bin/model/usuario_model.dart';
import 'package:selecaosicoob/bin/pages/agente/agente_controller.dart';

import '../../model/project_info_model.dart';
import '../../model/ticket_model.dart';

class AgenteView extends StatefulWidget {
  final Usuario usuario;
  const AgenteView({Key? key, required this.usuario}) : super(key: key);

  @override
  State<AgenteView> createState() => _AgenteViewState();
}

class _AgenteViewState extends State<AgenteView> {
  late AgenteController agenteController;

  @override
  void initState() {
    agenteController = AgenteController(usuario: widget.usuario);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    var size = MediaQuery.of(context).size;
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${GetIt.instance<ProjectInfo>().nome} - Painel Administrativo'),
      ),
      body: Flex(
        direction: Axis.vertical,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 60,
            width: size.width,
            child: AnimatedBuilder(
              animation: agenteController,
              builder: (context, child) {
                return Wrap(
                  spacing: 10,
                  children: [
                    FilterChip(
                      avatar: const Icon(Icons.schedule),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream: agenteController
                            .streamAtendimentosPendentesNoSetor(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 50,
                              //  height: 10,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Text(
                            'a Receber (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('aberto');
                      },
                      selected: (agenteController.selectedFilter == 'aberto'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.history),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream: agenteController
                            .streamGetMeusAtendimentosIniciados(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 50,
                              // height: 10,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Text(
                            'em Atendimento (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('atendimento');
                      },
                      selected:
                          (agenteController.selectedFilter == 'atendimento'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.task_alt),
                      showCheckmark: false,
                      label: StreamBuilder(
                        stream: agenteController
                            .streamGetMeusAtendimentosConcluidos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 50,
                              //  height: 10,
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Text(
                            'Concluidos (${snapshot.data!.length})',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                          );
                        },
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('concluido');
                      },
                      selected:
                          (agenteController.selectedFilter == 'concluido'),
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.add),
                      showCheckmark: false,
                      label: const Text(
                        'Novo Chamado',
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                      onSelected: (value) {},
                    ),
                    FilterChip(
                      avatar: const Icon(Icons.auto_graph_outlined),
                      showCheckmark: false,
                      label: const Text(
                        'Relatorios SLA',
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                      ),
                      onSelected: (value) {
                        agenteController.setFilter('sla');
                      },
                      selected: (agenteController.selectedFilter == 'sla'),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: agenteController,
              builder: (context, child) {
                return StreamBuilder(
                  stream: agenteController.streamWhereSelectedFilter(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return SizedBox(
                        width: size.width / 2,
                        child: Text('Erro ao buscar!\r\n${snapshot.error}'),
                      );
                    } else if (snapshot.hasData) {
                      return (agenteController.selectedFilter == 'sla')
                          ? agenteController.pageRelatorio(snapshot.data!)
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Ticket ticket = snapshot.data![index];
                                return ListTile(
                                  title: Text(
                                      '${ticket.assunto} - ${ticket.codigo}'),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<String>(
                                        future: agenteController
                                            .getUserCod(ticket.usuarioabertura),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text('- ');
                                          } else {
                                            return Text('- ${snapshot.data}');
                                          }
                                        },
                                      ),
                                      Text(
                                        '- ${DateFormat("dd/MM/yyy hh:mm:ss").format(ticket.abertura)}',
                                      ),
                                      Text(
                                        '- ${ticket.status}',
                                      ),
                                      FutureBuilder<String>(
                                        future: agenteController
                                            .getSetorName(ticket.setoratual),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Text('- ');
                                          } else {
                                            return Text('- ${snapshot.data}');
                                          }
                                        },
                                      ),
                                      Text(
                                        '- ${ticket.urgencia}',
                                      ),
                                    ],
                                  ),
                                  onTap: () {},
                                  leading: agenteController.getIconbyStatus(
                                    context,
                                    ticket.status,
                                  ),
                                  trailing:
                                      agenteController.ticketOption(ticket),
                                );
                              },
                            );
                    } else {
                      return const SizedBox(
                        child: Text('Sem Dados'),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget baseContainer({required Widget child, required Color cor}) {
    return Container(
      height: 180,
      width: 180,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: child,
    );
  }
}
