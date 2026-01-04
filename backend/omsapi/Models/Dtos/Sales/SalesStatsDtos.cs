namespace omsapi.Models.Dtos.Sales
{
    public class SalesDashboardStatsDto
    {
        public decimal MonthlyTarget { get; set; }
        public double MonthlyProgress { get; set; }
        public double QuarterlyProgress { get; set; }
        public int NewOpportunities { get; set; }
        public double NewOpportunitiesGrowth { get; set; }
        public double WinRate { get; set; }
        public double WinRateGrowth { get; set; }
    }

    public class TeamRankingDto
    {
        public int Rank { get; set; }
        public string Name { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public double Rate { get; set; }
    }
}
