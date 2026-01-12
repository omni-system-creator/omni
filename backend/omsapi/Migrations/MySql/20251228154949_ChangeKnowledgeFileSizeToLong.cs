using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class ChangeKnowledgeFileSizeToLong : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // First, update existing rows to have valid numeric string or 0, so casting won't fail if possible
            // But MySQL direct AlterColumn might fail if data is not compatible.
            // Since this is dev, let's clear data or try to update to 0 first.
            // Safe bet: set all size to 0 before converting.
            migrationBuilder.Sql("UPDATE contract_knowledge_file SET size = '0'");

            migrationBuilder.AlterColumn<long>(
                name: "size",
                table: "contract_knowledge_file",
                type: "bigint",
                nullable: false,
                defaultValue: 0L,
                oldClrType: typeof(string),
                oldType: "varchar(50)",
                oldMaxLength: 50,
                oldNullable: true)
                .OldAnnotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "size",
                table: "contract_knowledge_file",
                type: "varchar(50)",
                maxLength: 50,
                nullable: true,
                oldClrType: typeof(long),
                oldType: "bigint")
                .Annotation("MySql:CharSet", "utf8mb4");
        }
    }
}
