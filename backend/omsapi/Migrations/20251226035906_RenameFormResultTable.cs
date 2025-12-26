using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class RenameFormResultTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_form_result",
                table: "sys_form_result");

            migrationBuilder.RenameTable(
                name: "sys_form_result",
                newName: "frm_data");

            migrationBuilder.AddPrimaryKey(
                name: "PK_frm_data",
                table: "frm_data",
                column: "id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_frm_data",
                table: "frm_data");

            migrationBuilder.RenameTable(
                name: "frm_data",
                newName: "sys_form_result");

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_form_result",
                table: "sys_form_result",
                column: "id");
        }
    }
}
