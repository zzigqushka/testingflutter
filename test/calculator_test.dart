import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateNiceMocks([MockSpec<IDataSource>()])
import 'calculator_test.mocks.dart';


abstract class IDataSource {
  List<String> getTodoList();
}

class DataSource {
  List<String> getTodoList() => ['Task 1', 'Task 2'];
}

class Repository {
  IDataSource dataSource;

  Repository(this.dataSource);

  List<String> reversedTodoList() => dataSource.getTodoList().reversed.toList();
}

class Calculator {
  Future<int> testDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    return 42;
  }

  int sum(int a, int b) => a + b;
  int mul(int a, int b) => a * b;
  int div(int a, int b) => a ~/ b;
  List<String> names = ['Ivan', 'Maria'];
}

late Calculator c;

class ThirdLetter extends Matcher {
  final String chr;

  const ThirdLetter(this.chr);

  @override
  Description describe(Description description) {
    description.add('Check third letter for [$chr]');
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    matchState['real'] = item[2];
    return (item is String) && (item[2] == chr);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    mismatchDescription.add('Waiting for $chr, real is ${matchState['real']}');
    return mismatchDescription;
  }
}

void main() {
  setUpAll(() {
    c = Calculator();
  });

  group(
    'Calculator',
    () {
      test('TEst Sum', () {
        expect(c.sum(2, 4), 6);
        expect(c.names, hasLength(2), reason: 'Length is invalid');
        expect(c.names[0], startsWith('Iv'));
        // expect(c.div(2, 0), throwsUnsupportedError);
      });

      test('Test async', () async {
        fakeAsync((async) {
          //expect( c.testDelay(), 42);
         // expectLater(await c.testDelay(), 42);
          expect(Completer().future.timeout(Duration(seconds: 5)),
              throwsA(isA<TimeoutException>()));
          async.elapse(Duration(seconds: 5));
        });
      });

      test('Test string', () {
        expect(c.names[0], const ThirdLetter('a'));
      });

      test('Test mock', () {
        final r = MockIDataSource();
        final c = Repository(r);
        when(r.getTodoList()).thenReturn(['TestData1', 'TestData2']);
        print(c.reversedTodoList());
        verify(r.getTodoList()).called(1);
ghjg
      });
    },
  );
  tearDownAll(() {});
}
