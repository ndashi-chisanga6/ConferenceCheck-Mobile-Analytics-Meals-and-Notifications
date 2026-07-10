String percentageLabel(num value) =>
    '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}%';

double percentageOf(int part, int total) =>
    total <= 0 ? 0 : (part / total) * 100;
