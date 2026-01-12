using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddAnonce : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<int>(
                name: "Type",
                table: "sys_chat_conversation",
                type: "int",
                nullable: false,
                comment: "0=Private, 1=Group, 2=System, 3=App",
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<long>(
                name: "RelatedId",
                table: "sys_chat_conversation",
                type: "bigint",
                nullable: true,
                comment: "关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。",
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

            migrationBuilder.AlterColumn<decimal>(
                name: "Amount",
                table: "sales_registrations",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(65,30)");

            migrationBuilder.AlterColumn<decimal>(
                name: "amount",
                table: "sales_opportunity",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(65,30)");

            migrationBuilder.AlterColumn<decimal>(
                name: "score_weight",
                table: "sales_bid_chapter",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(65,30)",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "state",
                table: "bigview_project",
                type: "varchar(20)",
                maxLength: 20,
                nullable: true,
                comment: "状态 [-1未发布,1发布]",
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldMaxLength: 20,
                oldNullable: true)
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateTable(
                name: "sys_anonce",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false, comment: "主键ID")
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    Title = table.Column<string>(type: "varchar(200)", maxLength: 200, nullable: false, comment: "公告标题")
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Content = table.Column<string>(type: "longtext", nullable: false, comment: "公告内容")
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Type = table.Column<string>(type: "varchar(50)", maxLength: 50, nullable: false, comment: "公告类型 (关联字典 anonce_type)")
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Status = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, comment: "状态 (draft:草稿, published:已发布, revoked:已撤回)")
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    PublishTime = table.Column<DateTime>(type: "datetime(6)", nullable: true, comment: "发布时间"),
                    CreatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false, comment: "创建时间"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false, comment: "更新时间"),
                    CreatedBy = table.Column<long>(type: "bigint", nullable: true, comment: "创建人ID"),
                    UpdatedBy = table.Column<long>(type: "bigint", nullable: true, comment: "更新人ID"),
                    Priority = table.Column<string>(type: "varchar(20)", maxLength: 20, nullable: false, comment: "优先级 (high, normal, low)")
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_sys_anonce", x => x.Id);
                },
                comment: "系统公告表")
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "sys_anonce");

            migrationBuilder.AlterColumn<int>(
                name: "Type",
                table: "sys_chat_conversation",
                type: "int",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int",
                oldComment: "0=Private, 1=Group, 2=System, 3=App");

            migrationBuilder.AlterColumn<long>(
                name: "RelatedId",
                table: "sys_chat_conversation",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true,
                oldComment: "关联ID。 对于群组(Type=1)，此处存GroupId。 对于系统/应用(Type=2/3)，如果模块有ID则存ID；如果只有字符串代码(如 \"workflow\")，则此处存null，通过 ConversationKey 区分。");

            migrationBuilder.AlterColumn<decimal>(
                name: "Amount",
                table: "sales_registrations",
                type: "decimal(65,30)",
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldPrecision: 18,
                oldScale: 2);

            migrationBuilder.AlterColumn<decimal>(
                name: "amount",
                table: "sales_opportunity",
                type: "decimal(65,30)",
                nullable: false,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldPrecision: 18,
                oldScale: 2);

            migrationBuilder.AlterColumn<decimal>(
                name: "score_weight",
                table: "sales_bid_chapter",
                type: "decimal(65,30)",
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "decimal(18,2)",
                oldPrecision: 18,
                oldScale: 2,
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "state",
                table: "bigview_project",
                type: "varchar(20)",
                maxLength: 20,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(20)",
                oldMaxLength: 20,
                oldNullable: true,
                oldComment: "状态 [-1未发布,1发布]")
                .Annotation("MySql:CharSet", "utf8mb4")
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }
    }
}
