import 'package:flutter/material.dart';
import 'package:flutter_aierke_ros/bloc/user_bloc.dart';
import 'package:flutter_aierke_ros/counter_bloc.dart';
import 'package:flutter_aierke_ros/searchpage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Counter(),
    Searchpage(),
    Center(child: Text('Page 3')),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: '1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: '2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: '3',
          ),
        ],
      ),
    );
  }
}

class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counterBloc = CounterBloc();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => counterBloc,
        ),
        BlocProvider(
          create: (context) => UserBloc(counterBloc),
        ),
      ],
      child: MaterialApp(
        home: MyPage(),
      ),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      floatingActionButton: BlocConsumer<CounterBloc, int>(
        buildWhen: (prev, current) => prev > current,
        listenWhen: (prev, current) => prev > current,
        listener: (context, state) {
          if (state == 0) {
            Scaffold.of(context).showBottomSheet(
              (context) => Container(
                color: Colors.blue,
                width: double.infinity,
                height: 30,
                child: Text('State is 0'),
              ),
            );
          }
        },
        builder: (context, state) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.toString()),
            IconButton(
              onPressed: () {
                counterBloc.add(CounterIncEvent());
              },
              icon: const Icon(Icons.plus_one),
            ),
            IconButton(
              onPressed: () {
                counterBloc.add(CounterDecEvent());
              },
              icon: const Icon(Icons.exposure_minus_1),
            ),
            IconButton(
              onPressed: () {
                final userBloc = context.read<UserBloc>();
                userBloc
                    .add(UserGetUsersEvent(context.read<CounterBloc>().state));
              },
              icon: const Icon(Icons.person),
            ),
            IconButton(
              onPressed: () {
                final userBloc = context.read<UserBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Job(),
                  ),
                );
                userBloc.add(
                    UserGetUsersJobEvent(context.read<CounterBloc>().state));
              },
              icon: const Icon(Icons.work),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              BlocBuilder<CounterBloc, int>(
                // bloc: counterBloc,
                builder: (context, state) {
                  final users =
                      context.select((UserBloc bloc) => bloc.state.users);
                  return Column(
                    children: [
                      Text(state.toString(), style: TextStyle(fontSize: 33)),
                      if (users.isNotEmpty) ...users.map((e) => Text(e.name)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Job extends StatelessWidget {
  const Job({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          final job = state.job;
          return Column(
            children: [
              if (state.isLoading) const CircularProgressIndicator(),
              if (job.isNotEmpty) ...job.map((e) => Text(e.name)),
            ],
          );
        },
      ),
    );
  }
}
