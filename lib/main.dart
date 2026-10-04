import 'package:flutter/material.dart';

void main() {
  runApp(const SalaryCalculatorApp());
}

class SalaryCalculatorApp extends StatelessWidget {
  const SalaryCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirQuay TW 급여계산기 薪資計算器',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4B39EF)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
      ),
      home: const SalaryCalculatorPage(),
    );
  }
}

class SalaryCalculatorPage extends StatefulWidget {
  const SalaryCalculatorPage({super.key});

  @override
  State<SalaryCalculatorPage> createState() => _SalaryCalculatorPageState();
}

class _SalaryCalculatorPageState extends State<SalaryCalculatorPage> {
  // 收入相關
  final TextEditingController _baseSalaryController = TextEditingController(text: '0');
  final TextEditingController _mealnontaxableController = TextEditingController(text: '3000');
  final TextEditingController _mealtaxableController = TextEditingController(text: '1000');
  final TextEditingController _mobilephoneallowanceController = TextEditingController(text: '1000');
  final TextEditingController _festivalallowanceController = TextEditingController(text: '0');
  final TextEditingController _responsibilityallowanceController = TextEditingController(text: '0');
  final TextEditingController _educationsubsidyController = TextEditingController(text: '0');

  // 平日加班
  final TextEditingController _weekdayOt134Controller = TextEditingController(text: '0');
  final TextEditingController _weekdayOt167Controller = TextEditingController(text: '0');
  final TextEditingController _weekdayOt200Controller = TextEditingController(text: '0');

  // 休息日加班
  final TextEditingController _restDayOt134Controller = TextEditingController(text: '0');
  final TextEditingController _restDayOt167Controller = TextEditingController(text: '0');
  final TextEditingController _restDayOt267Controller = TextEditingController(text: '0');

  // 例假日與國定假日加班
  final TextEditingController _holidayDaysController = TextEditingController(text: '0');
  final TextEditingController _holidayOt200Controller = TextEditingController(text: '0');

  // 扣款相關
  final TextEditingController _laborInsuranceController = TextEditingController(text: '0');
  final TextEditingController _healthInsuranceController = TextEditingController(text: '0');
  final TextEditingController _pensionVoluntaryController = TextEditingController(text: '0');
  final TextEditingController _leaveFullDeductHoursController = TextEditingController(text: '0');
  final TextEditingController _leaveHalfDeductHoursController = TextEditingController(text: '0');

  // 計算結果
  double _grossPay = 0.0;
  double _totalDeductions = 0.0;
  double _netPay = 0.0;
  double _hourlyRate = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateSalary();
  }

  double _parseNum(String text) {
    return double.tryParse(text.trim()) ?? 0.0;
  }

  void _calculateSalary() {
    double base = _parseNum(_baseSalaryController.text);
    double mealnontaxable = _parseNum(_mealnontaxableController.text);
    double mealtaxable = _parseNum(_mealtaxableController.text);
    double mobilephoneallowance = _parseNum(_mobilephoneallowanceController.text);
    double festivalallowance = _parseNum(_festivalallowanceController.text);
    double responsibilityallowance = _parseNum(_responsibilityallowanceController.text);
    double educationsubsidy = _parseNum(_educationsubsidyController.text);
    
    // 每小時工資率 (月薪 / 240)
    double hourlyRate = (base + mealnontaxable + mealtaxable + responsibilityallowance + mobilephoneallowance) / 240.0;

    // --- 平日加班費（每項無條件進位） ---
    double weekdayOt = (_parseNum(_weekdayOt134Controller.text) * hourlyRate * 1.34).ceilToDouble() +
        (_parseNum(_weekdayOt167Controller.text) * hourlyRate * 1.67).ceilToDouble() +
        (_parseNum(_weekdayOt200Controller.text) * hourlyRate * 2.00).ceilToDouble();

    // --- 休息日加班費（每項無條件進位） ---
    double restDayOt = (_parseNum(_restDayOt134Controller.text) * hourlyRate * 1.34).ceilToDouble() +
        (_parseNum(_restDayOt167Controller.text) * hourlyRate * 1.67).ceilToDouble() +
        (_parseNum(_restDayOt267Controller.text) * hourlyRate * 2.67).ceilToDouble();

    // --- 例假日/國定假日加班費（每項無條件進位） ---
    double holidayOt = (_parseNum(_holidayDaysController.text) * hourlyRate * 8.0).ceilToDouble() +
        (_parseNum(_holidayOt200Controller.text) * hourlyRate * 2.00).ceilToDouble();

    double totalOvertime = weekdayOt + restDayOt + holidayOt;
    double gross = base + mealnontaxable + mealtaxable + mobilephoneallowance + responsibilityallowance + totalOvertime + festivalallowance + educationsubsidy;

    // --- 請假扣款（無條件進位） ---
    double leaveFullDeduct = (_parseNum(_leaveFullDeductHoursController.text) * hourlyRate).ceilToDouble();
    double leaveHalfDeduct = (_parseNum(_leaveHalfDeductHoursController.text) * hourlyRate * 0.5).ceilToDouble();

    // --- 總應扣金額 ---
    double deductions = _parseNum(_laborInsuranceController.text) +
        _parseNum(_healthInsuranceController.text) +
        _parseNum(_pensionVoluntaryController.text) +
        leaveFullDeduct +
        leaveHalfDeduct;

    setState(() {
      _hourlyRate = hourlyRate;
      _grossPay = gross;
      _totalDeductions = deductions;
      _netPay = gross - deductions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AirQuay TW 급여계산기 薪資計算器', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4B39EF),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth > 650) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildIncomeColumn()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDeductionColumn()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildIncomeColumn(),
                  const SizedBox(height: 16),
                  _buildDeductionColumn(),
                ],
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B39EF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _calculateSalary,
                child: const Text('計算薪資', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              color: const Color(0xFFF1F4F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildResultRow('基本時薪', 'NT\$ ${_hourlyRate.toStringAsFixed(2)}'),
                    const Divider(height: 20),
                    _buildResultRow('應付薪資總額 총지급액', 'NT\$ ${_grossPay.toStringAsFixed(0)}', isBold: true),
                    _buildResultRow('應扣薪資總額 총공제액', '- NT\$ ${_totalDeductions.toStringAsFixed(0)}', color: Colors.red),
                    const Divider(height: 20, thickness: 1.5),
                    _buildResultRow('實領薪資 실지급액', 'NT\$ ${_netPay.toStringAsFixed(0)}', fontSize: 22, color: const Color(0xFF4B39EF), isBold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeColumn() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('應付薪資 지급 항목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4B39EF))),
            ),
            const SizedBox(height: 12),
            _buildInputField('底薪 기본 급여', _baseSalaryController),
            _buildInputField('免稅伙食費 식대 비과세', _mealnontaxableController),
            _buildInputField('應稅伙食費 식대 과세', _mealtaxableController),
            _buildInputField('電信津貼 통신비', _mobilephoneallowanceController),
            _buildInputField('節日獎金 명절 상여금', _festivalallowanceController),
            _buildInputField('職務津貼 직무수당', _responsibilityallowanceController),
            _buildInputField('教育訓練費 자기개발비', _educationsubsidyController),
            const Divider(height: 24),
            const Text('平日加班(hr)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildInputField('前 2 小時 (*1.34)', _weekdayOt134Controller),
            _buildInputField('3~4 小時 (*1.67)', _weekdayOt167Controller),
            _buildInputField('超過 4 小時 (*2)', _weekdayOt200Controller),
            const Divider(height: 24),
            const Text('休息日加班(hr)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildInputField('前 2 小時 (*1.34)', _restDayOt134Controller),
            _buildInputField('3~8 小時 (*1.67)', _restDayOt167Controller),
            _buildInputField('第 9 小時起 (*2.67)', _restDayOt267Controller),
            const Divider(height: 24),
            const Text('例假日與國定假日', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildInputField('出勤天數 (8hr內給1日薪)', _holidayDaysController),
            _buildInputField('超過 8 小時計時 (*2)', _holidayOt200Controller),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionColumn() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('應扣薪資 공제 항목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            const SizedBox(height: 12),
            _buildInputField('勞保費 노동보험료', _laborInsuranceController),
            _buildInputField('健保費 건강보험료', _healthInsuranceController),
            _buildInputField('自提勞退 퇴직연금 자진적립', _pensionVoluntaryController),
            const Divider(height: 24),
            const Text('請假扣薪 (時數)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildInputField('扣全薪時數 (事假/留職停薪 무급휴가)', _leaveFullDeductHoursController),
            _buildInputField('扣半薪時數 (病假 병가)', _leaveHalfDeductHoursController),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          SizedBox(
            width: 85,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String title, String val, {double fontSize = 15, Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontSize: fontSize, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}