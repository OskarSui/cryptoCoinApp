import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movieapp/features/crypto_list/bloc/crypto_list_bloc.dart';
import 'package:movieapp/features/crypto_list/widgets/widgets.dart';
import 'package:movieapp/repositories/crypto_coins/abstract_coins_repository.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final _cryptoListBloc = CryptoListBloc(
    GetIt.I<AbstractCoinsRepository>(),
  );

  @override
  void initState() {
    _cryptoListBloc.add(LoadCryptoList(completer: null));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CryptoCurrencyList'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final completer = Completer();
            _cryptoListBloc.add(LoadCryptoList(completer: completer));
            return completer.future;
          },
          child: BlocBuilder<CryptoListBloc, CryptoListState>(
            bloc: _cryptoListBloc,
            builder: (context, state) {
              if (state is CryptoListLoaded) {
                return ListView.separated(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: state.coinsList.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final coin = state.coinsList[i];
                    return CryptoCoinTile(coin: coin);
                  },
                );
              }
              if (state is CryptoListLoadingFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Somethind went wrong',
                        // style: theme.textTheme.labelSmall?.copyWith(fonSize:16),
                      ),
                      const Text('Please try again later'),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          _cryptoListBloc.add(LoadCryptoList(completer: null));
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }
}
