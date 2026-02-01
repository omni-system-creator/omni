namespace omsapi.Models.Enums
{
    /// <summary>
    /// 账款状态
    /// </summary>
    public enum FinanceBillStatus
    {
        Pending = 0,    // 待处理
        Approved = 1,   // 已审核/待支付/待收款
        Partial = 2,    // 部分结算
        Paid = 3,       // 已完成/已结清
        Cancelled = 4   // 已取消
    }

    /// <summary>
    /// 财务科目方向
    /// </summary>
    public static class FinanceDirection
    {
        public const string Income = "income";   // 收入/应收
        public const string Expense = "expense"; // 支出/应付
    }

    /// <summary>
    /// 账款类型
    /// </summary>
    public static class FinanceBillType
    {
        public const string AP = "AP"; // 应付 (Accounts Payable)
        public const string AR = "AR"; // 应收 (Accounts Receivable)
    }

    /// <summary>
    /// 附件目标类型
    /// </summary>
    public static class FinanceTargetType
    {
        public const string ApAr = "ApAr";
        public const string Invoice = "Invoice";
        public const string Subject = "Subject";
    }
}
