using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.SqlServer
{
    /// <inheritdoc />
    public partial class AddCustomerCreditCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "org_id",
                table: "sales_script",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "OrgId",
                table: "sales_registrations",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "org_id",
                table: "sales_product_doc",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "org_id",
                table: "sales_process_rule",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<string>(
                name: "credit_code",
                table: "sales_customer",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<long>(
                name: "org_id",
                table: "sales_customer",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<string>(
                name: "type",
                table: "contract_payment_record",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "voucher_file_name",
                table: "contract_payment_record",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "voucher_file_path",
                table: "contract_payment_record",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "lifecycle_status",
                table: "contract_main",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "pricing_type",
                table: "contract_main",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "attachment_file_name",
                table: "contract_invoice",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "attachment_file_path",
                table: "contract_invoice",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "direction",
                table: "contract_invoice",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "contract_relation",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    contract_id = table.Column<long>(type: "bigint", nullable: false),
                    related_contract_id = table.Column<long>(type: "bigint", nullable: false),
                    created_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_contract_relation", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "project_members",
                columns: table => new
                {
                    id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    project_code = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    username = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    role = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    joined_at = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_project_members", x => x.id);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "contract_relation");

            migrationBuilder.DropTable(
                name: "project_members");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_script");

            migrationBuilder.DropColumn(
                name: "OrgId",
                table: "sales_registrations");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_product_doc");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_process_rule");

            migrationBuilder.DropColumn(
                name: "credit_code",
                table: "sales_customer");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_customer");

            migrationBuilder.DropColumn(
                name: "type",
                table: "contract_payment_record");

            migrationBuilder.DropColumn(
                name: "voucher_file_name",
                table: "contract_payment_record");

            migrationBuilder.DropColumn(
                name: "voucher_file_path",
                table: "contract_payment_record");

            migrationBuilder.DropColumn(
                name: "lifecycle_status",
                table: "contract_main");

            migrationBuilder.DropColumn(
                name: "pricing_type",
                table: "contract_main");

            migrationBuilder.DropColumn(
                name: "attachment_file_name",
                table: "contract_invoice");

            migrationBuilder.DropColumn(
                name: "attachment_file_path",
                table: "contract_invoice");

            migrationBuilder.DropColumn(
                name: "direction",
                table: "contract_invoice");
        }
    }
}
