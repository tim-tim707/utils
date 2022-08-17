# References and names of data points

# https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/edit#
# https://w3c.github.io/paint-timing/

# "args":
#     "data":
#         "documentLoaderURL": "" | "https://www.example.com",
# "name": "navigationStart",

# "name": "firstContentfulPaint",

#  "name": "NavStartToLargestContentfulPaint::AllFrames::UMA",

# "args":
#     "data":
#         "type": "DOMContentLoaded"
# "name": "EventDispatch",

import sys
import json
import math
import csv

FCP = "First_Contentful_Paint"
DCL = "Dom_Content_Load"
LCP = "Largest_Contentful_Paint"


def main(filename: str):
    print("File to extract data from: ", filename)
    file = open(filename)
    print("Loading data...")
    data = json.load(file)
    print("Data loaded...")
    file.close()

    def sorter(item):
        return item["ts"]
    data["traceEvents"].sort(key=sorter)

    currentTimeStamp = math.inf
    navigationStarted = False
    item = None
    items = []
    for event in data["traceEvents"]:
        if (event["name"].startswith("navigationStart")
                and event["args"]["data"]["documentLoaderURL"] != ""):
            print("Navigation start")
            currentTimeStamp = event["ts"]
            navigationStarted = True
            if (item != None):
                items.append(item)
            item = {"navigationItem": len(items)}
        elif (navigationStarted):
            if (event["name"].startswith("firstContentfulPaint")):
                duration = (event["ts"] - currentTimeStamp) / 1000000
                print(FCP, duration)
                item[FCP] = duration
            elif (event["name"].startswith("EventDispatch")
                  and event["args"]["data"]["type"].startswith("DOMContentLoaded")
                  and not "stackTrace" in event["args"]["data"]):
                duration = (event["ts"] - currentTimeStamp) / 1000000
                print(DCL, duration)
                item[DCL] = duration
            elif (event["name"].startswith("NavStartToLargestContentfulPaint::AllFrames")):
                duration = (event["ts"] - currentTimeStamp) / 1000000
                print(LCP, duration)
                item[LCP] = duration

    fcp = []
    dcl = []
    lcp = []
    totals = []
    for item in items:
        fcp.append(item[FCP])
        dcl.append(item[DCL])
        lcp.append(item[LCP])
        item["Total"] = item[FCP] + item[DCL] + item[LCP]
        totals.append(item["Total"])

    print("Writing output to ./output.csv...")
    with open("output.csv", "w", encoding="UTF8", newline='') as f:
        writer = csv.DictWriter(
            f, fieldnames=["navigationItem", FCP, DCL, LCP, "Total"])
        writer.writeheader()
        writer.writerows(items)

    file = open("output.csv", "a", encoding="UTF8")
    file.write("\n")
    length = len(fcp)
    file.write(
        f"Average: {(sum(fcp) / length):.2f}, {(sum(dcl) / length):.2f},{(sum(lcp) / length):.2f}, {(sum(totals) / length):.2f}")
    file.write("\n")
    file.write(
        f"Minimum: {min(fcp):.2f}, {min(dcl):.2f}, {min(lcp):.2f}, {min(totals):.2f}")
    file.write("\n")
    file.write(
        f"Maximum: {max(fcp):.2f}, {max(dcl):.2f}, {max(lcp):.2f}, {max(totals):.2f}")
    file.close()
    print("Writing done")
    return 0


if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print("Usage: python TraceEventToCSV.py myChrometrace.json")
        sys.exit(1)
    main(sys.argv[1])
