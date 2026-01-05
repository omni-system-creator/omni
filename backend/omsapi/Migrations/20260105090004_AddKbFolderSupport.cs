using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class AddKbFolderSupport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsFolder",
                table: "kb_file",
                type: "tinyint(1)",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<Guid>(
                name: "ParentId",
                table: "kb_file",
                type: "char(36)",
                nullable: true,
                collation: "ascii_general_ci");

            migrationBuilder.CreateIndex(
                name: "IX_kb_file_ParentId",
                table: "kb_file",
                column: "ParentId");

            migrationBuilder.AddForeignKey(
                name: "FK_kb_file_kb_file_ParentId",
                table: "kb_file",
                column: "ParentId",
                principalTable: "kb_file",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_kb_file_kb_file_ParentId",
                table: "kb_file");

            migrationBuilder.DropIndex(
                name: "IX_kb_file_ParentId",
                table: "kb_file");

            migrationBuilder.DropColumn(
                name: "IsFolder",
                table: "kb_file");

            migrationBuilder.DropColumn(
                name: "ParentId",
                table: "kb_file");
        }
    }
}
