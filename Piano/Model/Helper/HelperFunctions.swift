import Foundation

func nextMultiple(of y: Int, after x: Int) -> Int {
    let remainder = x % y
    return remainder == 0 ? x : x + (y - remainder)
}

func divideRoundedUp(_ a: Int, _ b: Int) -> Int {
    (a + b - 1) / b
}



func timerStream(interval: TimeInterval) -> AsyncStream<Int> {
    AsyncStream { continuation in
        var beat = 0

        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .userInitiated))
        timer.schedule(deadline: .now(), repeating: interval, leeway: .milliseconds(1))
        timer.setEventHandler {
            continuation.yield(beat)
            beat += 1
        }

        timer.resume()

        continuation.onTermination = { @Sendable _ in
            timer.cancel()
        }
    }
}

func allAcceptableSets(allNumbers: Set<Int>, omittableNumbers: Set<Int>) -> [Set<Int>] {
    let omittableArray = Array(omittableNumbers)
    var results: [Set<Int>] = []

    // 2^n combinations of omittable elements
    let count = 1 << omittableArray.count
    for mask in 0..<count {
        var subsetToOmit: Set<Int> = []
        for i in 0..<omittableArray.count {
            if (mask & (1 << i)) != 0 {
                subsetToOmit.insert(omittableArray[i])
            }
        }

        // Omit the subset from allNumbers
        let acceptable = allNumbers.subtracting(subsetToOmit)
        results.append(acceptable)
    }

    return results
}

