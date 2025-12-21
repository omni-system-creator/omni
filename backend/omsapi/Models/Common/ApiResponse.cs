namespace omsapi.Models.Common
{
    public class ApiResponse<T>
    {
        public int Code { get; set; }
        public string Msg { get; set; } = string.Empty;
        public T? Data { get; set; }

        public ApiResponse() { }

        public ApiResponse(int code, string msg, T? data = default)
        {
            Code = code;
            Msg = msg;
            Data = data;
        }

        public static ApiResponse<T> Success(T data, string msg = "Success")
        {
            return new ApiResponse<T>(200, msg, data);
        }

        public static ApiResponse<T> Error(string msg = "Error", int code = 500)
        {
            return new ApiResponse<T>(code, msg);
        }
    }
}
