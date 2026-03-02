import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const TaxMockApp());

class TaxMockApp extends StatelessWidget {
  const TaxMockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '个人所得税',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ================== 模拟登录页 ==================
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, size: 120, color: Colors.white),
                const SizedBox(height: 20),
                const Text('个人所得税', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                const Text('国家税务总局', style: TextStyle(fontSize: 18, color: Colors.white70)),
                const SizedBox(height: 60),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('快速登录（模拟）', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                const Text('点击即模拟人脸识别登录', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================== 首页 ==================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const QueryTab(),
    const CalculatorTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '查询'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: '计算'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

// ================== 首页Tab ==================
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 大Banner
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('人人我为我 我为人人', style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('国家税务总局', style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 快捷卡片
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: [
                _buildCard('收入纳税明细', Icons.receipt_long, Colors.blue),
                _buildCard('专项附加扣除', Icons.family_restroom, Colors.purple),
                _buildCard('年度汇算', Icons.calendar_month, Colors.orange),
                _buildCard('办税服务', Icons.payment, Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {}, // 后面可以跳转
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ================== 查询Tab（收入明细核心）==================
class QueryTab extends StatefulWidget {
  const QueryTab({super.key});
  @override
  State<QueryTab> createState() => _QueryTabState();
}

class _QueryTabState extends State<QueryTab> {
  List<Map<String, dynamic>> records = [];
  final TextEditingController _yearController = TextEditingController(text: '2025');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('tax_records');
    if (json != null) {
      setState(() => records = List<Map<String, dynamic>>.from(jsonDecode(json)));
    } else {
      // 默认假数据
      records = [
        {'month': '1月', 'income': 15000, 'tax': 345},
        {'month': '2月', 'income': 18000, 'tax': 645},
      ];
      _saveData();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tax_records', jsonEncode(records));
  }

  void _addRecord() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('添加收入记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: '月份'), onChanged: (v) => month = v),
            TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '收入'), onChanged: (v) => income = double.tryParse(v) ?? 0),
            TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '税款'), onChanged: (v) => tax = double.tryParse(v) ?? 0),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              setState(() {
                records.add({'month': month, 'income': income, 'tax': tax});
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  String month = '';
  double income = 0;
  double tax = 0;

  @override
  Widget build(BuildContext context) {
    double totalIncome = records.fold(0, (p, e) => p + (e['income'] as double));
    double totalTax = records.fold(0, (p, e) => p + (e['tax'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('收入纳税明细查询')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('所属年度：'),
                Expanded(child: TextField(controller: _yearController, decoration: const InputDecoration(border: OutlineInputBorder()))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('收入合计：¥${totalIncome.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('已申报税额：¥${totalTax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, i) {
                final r = records[i];
                return ListTile(
                  title: Text('${r['month']}  ${r['income']}元'),
                  subtitle: Text('税款：${r['tax']}元'),
                  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () {
                    setState(() => records.removeAt(i));
                    _saveData();
                  }),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ================== 计算器Tab ==================
class CalculatorTab extends StatefulWidget {
  const CalculatorTab({super.key});
  @override
  State<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends State<CalculatorTab> {
  double salary = 15000;
  double deduction = 0;

  double calculateTax(double taxable) {
    if (taxable <= 0) return 0;
    // 简化个税速算（实际更复杂，这里给个近似）
    if (taxable <= 36000) return taxable * 0.03;
    if (taxable <= 144000) return taxable * 0.1 - 2520;
    return taxable * 0.2 - 16920; // 继续简化
  }

  @override
  Widget build(BuildContext context) {
    double taxable = (salary * 12) - 60000 - deduction; // 年应税所得
    double tax = calculateTax(taxable);

    return Scaffold(
      appBar: AppBar(title: const Text('税款计算模拟')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('月薪：¥${salary.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22)),
            Slider(value: salary, min: 5000, max: 50000, onChanged: (v) => setState(() => salary = v)),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: '专项附加扣除总额（子女教育+房贷等）'),
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => deduction = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 40),
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('年度应纳税所得额：¥${taxable.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('应缴税款：¥${tax.toStringAsFixed(2)}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red)),
                    const Text('（模拟计算，非官方结果）'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== 个人中心Tab ==================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('姓名'), subtitle: Text('张三'), trailing: Icon(Icons.edit)),
          ListTile(title: Text('身份证号'), subtitle: Text('110101********1234')),
          ListTile(title: Text('纳税识别号'), subtitle: Text('333388********8020')),
          ListTile(title: Text('手机号码'), subtitle: Text('138****8888')),
          Divider(),
          ListTile(title: Text('关于'), subtitle: Text('本App为本地模拟器，仅供娱乐\n数据全部保存在您手机上')),
        ],
      ),
    );
  }
}