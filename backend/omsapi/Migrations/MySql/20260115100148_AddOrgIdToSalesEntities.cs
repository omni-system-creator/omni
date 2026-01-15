using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations.MySql
{
    /// <inheritdoc />
    public partial class AddOrgIdToSalesEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {


            migrationBuilder.AlterColumn<long>(
                name: "OrgId",
                table: "sales_registrations",
                type: "bigint",
                nullable: false,
                defaultValue: 0L,
                oldClrType: typeof(long),
                oldType: "bigint",
                oldNullable: true);

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
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_script");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_product_doc");

            migrationBuilder.DropColumn(
                name: "org_id",
                table: "sales_process_rule");


            migrationBuilder.AlterColumn<long>(
                name: "OrgId",
                table: "sales_registrations",
                type: "bigint",
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint");
        }
    }
}
