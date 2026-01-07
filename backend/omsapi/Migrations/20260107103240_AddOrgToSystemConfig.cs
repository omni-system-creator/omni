using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddOrgToSystemConfig : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_sys_config_Key",
                table: "sys_config");

            migrationBuilder.AddColumn<bool>(
                name: "IsOverridable",
                table: "sys_config",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<long>(
                name: "OrgId",
                table: "sys_config",
                type: "bigint",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 1L,
                columns: new[] { "IsOverridable", "OrgId" },
                values: new object[] { true, null });

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 2L,
                columns: new[] { "IsOverridable", "OrgId" },
                values: new object[] { true, null });

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 3L,
                columns: new[] { "IsOverridable", "OrgId" },
                values: new object[] { true, null });

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 4L,
                columns: new[] { "IsOverridable", "OrgId" },
                values: new object[] { true, null });

            migrationBuilder.UpdateData(
                table: "sys_config",
                keyColumn: "Id",
                keyValue: 5L,
                columns: new[] { "IsOverridable", "OrgId" },
                values: new object[] { true, null });

            migrationBuilder.CreateIndex(
                name: "IX_sys_config_Key_OrgId",
                table: "sys_config",
                columns: new[] { "Key", "OrgId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_sys_config_Key_OrgId",
                table: "sys_config");

            migrationBuilder.DropColumn(
                name: "IsOverridable",
                table: "sys_config");

            migrationBuilder.DropColumn(
                name: "OrgId",
                table: "sys_config");

            migrationBuilder.CreateIndex(
                name: "IX_sys_config_Key",
                table: "sys_config",
                column: "Key",
                unique: true);
        }
    }
}
