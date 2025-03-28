import 'package:event_poll/configs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../states/polls_state.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    final pollsState = Provider.of<PollsState>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => pollsState.fetchPolls(),
          ),
        ],
      ),
      body: _buildBody(context, pollsState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/polls/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PollsState pollsState) {
    if (pollsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pollsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pollsState.error!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => pollsState.fetchPolls(),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (pollsState.polls.isEmpty) {
      return const Center(
        child: Text("Aucun événement trouvé."),
      );
    }

    return ListView.builder(
      itemCount: pollsState.polls.length,
      itemBuilder: (context, index) {
        final poll = pollsState.polls[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/polls/detail',
                arguments: poll,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (poll.imageName != null)
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            '${Configs.baseUrl}/images/${poll.imageName}',
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.white),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poll.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          poll.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('E. dd MMMM yyyy').format(poll.eventDate),
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
