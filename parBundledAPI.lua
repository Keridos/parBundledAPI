-- Call "parallel.waitForAny(main,function() parBundledAPI.waitForData("top") end)" in your program and
-- put the stuff you need to do in function main(). That will execute your program and the listening process at the same time.
-- This way the listening is done completely in the background and does not interfere with your program.
-- The program needs 10 data lines, 8 bit data, 1 clock and 1 TX/"i am sending" bit.
-- The first 8 colors are data, the 9th is the clock and the 10th is TX. The 11th color needs to be a Receiver for the TX bit,
-- to see if other computers are sending. This enables multiple senders.

function getVersion()
	return 0.1
end

function sendData(side,data)
	local stringint
	while colors.test(rs.getBundledInput(side), 1024) do
		os.sleep(1)
	end
	rs.setBundledOutput(side,512)
	os.sleep(0.5)
	for i=1,string.len(data) do
		stringint = string.byte(string.sub(data,i))
		rs.setBundledOutput(side,colors.combine(768,stringint))
		os.sleep(0.15)
		rs.setBundledOutput(side,colors.combine(512,stringint))
		os.sleep(0.15)
	end
	os.sleep(0.25)
	rs.setBundledOutput(side,0)
	return true
end

function receiveData(side)
	local stringdata = ""
	while colors.test(rs.getBundledInput(side),512) do
		local event = os.pullEvent("redstone")
		if colors.test(rs.getBundledInput(side),256) then
			stringdata = stringdata..string.char(rs.getBundledInput(side)-768)
		end
		os.sleep(0.05)
	end
	return stringdata
end

function waitForData(side)
	while true do
		local event = os.pullEvent()
		if (event == "redstone")and(colors.test(rs.getBundledInput(side),512)) then
			os.queueEvent("RSData",receiveData(side))
		elseif (event == "stopListening") then
			break
		end
	end
end

function stopListening()
	os.queueEvent("stopListening")
	return true
end