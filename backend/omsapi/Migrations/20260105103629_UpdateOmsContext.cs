using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace omsapi.Migrations
{
    /// <inheritdoc />
    public partial class UpdateOmsContext : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_kb_node_source_kb_node_NodeId",
                table: "kb_node_source");

            migrationBuilder.DropTable(
                name: "kb_node");

            migrationBuilder.DropIndex(
                name: "IX_kb_node_source_NodeId",
                table: "kb_node_source");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "kb_node",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    KbId = table.Column<Guid>(type: "char(36)", nullable: false, collation: "ascii_general_ci"),
                    ParentId = table.Column<Guid>(type: "char(36)", nullable: true, collation: "ascii_general_ci"),
                    Content = table.Column<string>(type: "longtext", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Key = table.Column<string>(type: "varchar(100)", maxLength: 100, nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    Summary = table.Column<string>(type: "text", nullable: true)
                        .Annotation("MySql:CharSet", "utf8mb4"),
                    Title = table.Column<string>(type: "varchar(255)", maxLength: 255, nullable: false)
                        .Annotation("MySql:CharSet", "utf8mb4")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kb_node", x => x.Id);
                    table.ForeignKey(
                        name: "FK_kb_node_kb_info_KbId",
                        column: x => x.KbId,
                        principalTable: "kb_info",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_kb_node_kb_node_ParentId",
                        column: x => x.ParentId,
                        principalTable: "kb_node",
                        principalColumn: "Id");
                })
                .Annotation("MySql:CharSet", "utf8mb4");

            migrationBuilder.CreateIndex(
                name: "IX_kb_node_source_NodeId",
                table: "kb_node_source",
                column: "NodeId");

            migrationBuilder.CreateIndex(
                name: "IX_kb_node_KbId",
                table: "kb_node",
                column: "KbId");

            migrationBuilder.CreateIndex(
                name: "IX_kb_node_ParentId",
                table: "kb_node",
                column: "ParentId");

            migrationBuilder.AddForeignKey(
                name: "FK_kb_node_source_kb_node_NodeId",
                table: "kb_node_source",
                column: "NodeId",
                principalTable: "kb_node",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
