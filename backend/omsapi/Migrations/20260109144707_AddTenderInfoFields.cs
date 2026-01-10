using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddTenderInfoFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "agency_name",
                table: "sales_bid_analysis",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<DateTime>(
                name: "bid_end_time",
                table: "sales_bid_analysis",
                type: "datetime(6)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "bid_start_time",
                table: "sales_bid_analysis",
                type: "datetime(6)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "contact_name",
                table: "sales_bid_analysis",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "contact_phone",
                table: "sales_bid_analysis",
                type: "longtext",
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<DateTime>(
                name: "open_bid_time",
                table: "sales_bid_analysis",
                type: "datetime(6)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "tender_start_time",
                table: "sales_bid_analysis",
                type: "datetime(6)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "agency_name",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "bid_end_time",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "bid_start_time",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "contact_name",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "contact_phone",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "open_bid_time",
                table: "sales_bid_analysis");

            migrationBuilder.DropColumn(
                name: "tender_start_time",
                table: "sales_bid_analysis");
        }
    }
}
