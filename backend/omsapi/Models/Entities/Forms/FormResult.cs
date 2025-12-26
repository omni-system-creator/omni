using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace omsapi.Models.Entities.Forms
{
    [Table("frm_data")]
    public class FormResult
    {
        [Key]
        [Column("id")]
        public long Id { get; set; }

        [Column("form_id")]
        public long FormId { get; set; }

        // Storing JSON data as string. 
        [Column("data")] 
        public string Data { get; set; }

        [Column("submitted_at")]
        public DateTime SubmittedAt { get; set; } = DateTime.Now;

        [Column("submitted_by")]
        [StringLength(100)]
        public string SubmittedBy { get; set; } // Username or IP
    }
}
