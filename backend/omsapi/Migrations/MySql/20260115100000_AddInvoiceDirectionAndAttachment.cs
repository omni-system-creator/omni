using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.MySql
{
    public partial class AddInvoiceDirectionAndAttachment : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "direction",
                table: "contract_invoice",
                type: "varchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "output")
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "attachment_file_name",
                table: "contract_invoice",
                type: "varchar(255)",
                maxLength: 255,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.AddColumn<string>(
                name: "attachment_file_path",
                table: "contract_invoice",
                type: "varchar(255)",
                maxLength: 255,
                nullable: true)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "direction",
                table: "contract_invoice");

            migrationBuilder.DropColumn(
                name: "attachment_file_name",
                table: "contract_invoice");

            migrationBuilder.DropColumn(
                name: "attachment_file_path",
                table: "contract_invoice");
        }
    }
}

