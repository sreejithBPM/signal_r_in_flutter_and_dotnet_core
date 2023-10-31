using Microsoft.AspNetCore.SignalR;

namespace SignalRDemo.Hubs
{
    public class ChatHub : Hub
    {
        public async Task SendMessage(string user, string message)
        {
            await Clients.All.SendAsync("ReceiveMessage", user, message);
        }
        public async Task SendTypingStatus(string user, bool isTyping)
        {
            await Clients.All.SendAsync("ReceiveTypingStatus", user, isTyping);
        }

    }
}
