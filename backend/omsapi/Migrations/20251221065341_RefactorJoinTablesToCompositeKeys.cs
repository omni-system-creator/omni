using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class RefactorJoinTablesToCompositeKeys : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("SET FOREIGN_KEY_CHECKS = 0;");

            migrationBuilder.Sql("ALTER TABLE `sys_user_role` DROP FOREIGN KEY `FK_sys_user_role_sys_user_UserId`;");
            migrationBuilder.Sql("ALTER TABLE `sys_user_role` DROP FOREIGN KEY `FK_sys_user_role_sys_role_RoleId`;");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_user_role",
                table: "sys_user_role");

            migrationBuilder.DropIndex(
                name: "IX_sys_user_role_UserId_RoleId",
                table: "sys_user_role");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_role_permission",
                table: "sys_role_permission");

            migrationBuilder.DropIndex(
                name: "IX_sys_role_permission_RoleId_PermissionId",
                table: "sys_role_permission");

            migrationBuilder.DeleteData(
                table: "sys_user_role",
                keyColumn: "Id",
                keyColumnType: "bigint",
                keyValue: 1L);

            migrationBuilder.DropColumn(
                name: "Id",
                table: "sys_user_role");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "sys_role_permission");

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_user_role",
                table: "sys_user_role",
                columns: new[] { "UserId", "RoleId" });

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_role_permission",
                table: "sys_role_permission",
                columns: new[] { "RoleId", "PermissionId" });

            migrationBuilder.InsertData(
                table: "sys_user_role",
                columns: new[] { "RoleId", "UserId", "CreatedAt" },
                values: new object[] { 1L, 1L, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_role_sys_user_UserId",
                table: "sys_user_role",
                column: "UserId",
                principalTable: "sys_user",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_sys_user_role_sys_role_RoleId",
                table: "sys_user_role",
                column: "RoleId",
                principalTable: "sys_role",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.Sql("SET FOREIGN_KEY_CHECKS = 1;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_user_role",
                table: "sys_user_role");

            migrationBuilder.DropPrimaryKey(
                name: "PK_sys_role_permission",
                table: "sys_role_permission");

            migrationBuilder.DeleteData(
                table: "sys_user_role",
                keyColumns: new[] { "RoleId", "UserId" },
                keyValues: new object[] { 1L, 1L });

            migrationBuilder.AddColumn<long>(
                name: "Id",
                table: "sys_user_role",
                type: "bigint",
                nullable: false,
                defaultValue: 0L)
                .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn);

            migrationBuilder.AddColumn<long>(
                name: "Id",
                table: "sys_role_permission",
                type: "bigint",
                nullable: false,
                defaultValue: 0L)
                .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn);

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_user_role",
                table: "sys_user_role",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_sys_role_permission",
                table: "sys_role_permission",
                column: "Id");

            migrationBuilder.InsertData(
                table: "sys_user_role",
                columns: new[] { "Id", "CreatedAt", "RoleId", "UserId" },
                values: new object[] { 1L, new DateTime(2024, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1L, 1L });

            migrationBuilder.CreateIndex(
                name: "IX_sys_user_role_UserId_RoleId",
                table: "sys_user_role",
                columns: new[] { "UserId", "RoleId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_sys_role_permission_RoleId_PermissionId",
                table: "sys_role_permission",
                columns: new[] { "RoleId", "PermissionId" },
                unique: true);
        }
    }
}
