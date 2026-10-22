const homeDailyMessages = <String>[
  'Tâm tĩnh thì trí sáng. Hãy dành một nhịp chậm để nhìn rõ cơ hội đang đến gần.',
  'Một lựa chọn nhỏ hôm nay có thể mở ra hành trình lớn. Hãy tin vào trực giác của bạn.',
  'Khi lòng an định, mọi việc dần sáng rõ. Hôm nay thích hợp để bắt đầu điều bạn ấp ủ.',
  'Đừng vội trước những đổi thay. Bình tâm quan sát, bạn sẽ nhận ra hướng đi phù hợp.',
  'Vận may đến từ sự chuẩn bị. Hãy hoàn thành việc còn dang dở và đón cơ hội mới.',
  'Một cuộc gặp gỡ bất ngờ có thể mang đến gợi ý quý giá. Hãy lắng nghe bằng thiện tâm.',
  'Hôm nay nên nói lời chân thành. Sự thấu hiểu sẽ giúp một mối quan hệ thêm bền chặt.',
  'Giữ lòng rộng mở nhưng đừng quên giới hạn. Bình an bắt đầu từ việc trân trọng chính mình.',
  'Đi chậm không có nghĩa là dừng lại. Mỗi bước vững vàng đều đưa bạn gần hơn tới mục tiêu.',
  'Nguồn năng lượng mới đang đến. Hãy sắp xếp lại ưu tiên và dành sức cho điều quan trọng.',
  'Có những câu trả lời chỉ xuất hiện khi lòng yên. Hãy cho bản thân một khoảng lặng hôm nay.',
  'Tài lộc đến từ sự tỉnh táo và kiên trì. Đừng quyết định vội khi thông tin còn chưa rõ ràng.',
  'Một cánh cửa khép lại để nhường chỗ cho cơ hội khác. Hãy đón nhận thay đổi bằng niềm tin.',
  'Hôm nay phù hợp để kết nối và sẻ chia. Một lời động viên đúng lúc sẽ mang lại nhiều ấm áp.',
  'Trực giác đang dẫn đường, nhưng lý trí sẽ giúp bạn đi xa. Hãy cân bằng cả hai trước lựa chọn.',
  'Đừng để lo âu che khuất điều tốt đẹp. Tập trung vào việc bạn có thể làm ngay trong hôm nay.',
  'Sự kiên nhẫn sẽ được đền đáp. Hãy tiếp tục vun bồi kế hoạch thay vì nóng lòng thấy kết quả.',
  'Một ngày thuận lợi để học hỏi điều mới. Kiến thức hôm nay sẽ trở thành cơ hội trong tương lai.',
  'Hãy biết ơn những điều đang có. Năng lượng tích cực sẽ dẫn bạn tới những duyên lành mới.',
  'Thời vận chuyển mình từ những hành động nhỏ. Hãy bắt đầu bằng một việc tốt và làm thật trọn vẹn.',
];

/// Chọn ổn định theo ngày địa phương: không đổi khi widget rebuild, đổi vào ngày mới.
String dailyMessageFor(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day)
          .millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  final index = (day * 17 + 11) % homeDailyMessages.length;
  return homeDailyMessages[index];
}
