using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddSalesTenderAnalysisFileFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "file_id",
                table: "sales_bid_analysis",
                type: "bigint",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "file_name",
                table: "sales_bid_analysis",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "file_url",
                table: "sales_bid_analysis",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "file_id",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "file_name",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "file_url",
                table: "sales_bid_analysis");
        }
    }
}
